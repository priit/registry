# frozen_string_literal: true

class CsyncJob < Que::Job
  def run(generate: false)
    @store = {}
    @input_store = { secure: {}, insecure: {} }
    @results = {}
    @logger = Rails.env.test? ? Rails.logger : Logger.new(STDOUT)
    generate ? generate_scanner_input : process_scanner_results

    @logger.info 'CsyncJob: Finished.'
  end

  def qualified_for_monitoring?(domain, data)
    result_types = data[:ns].map { |ns| ns[:type] }.uniq
    ns_ok =  redundant_data_for?(nameserver: true, input: result_types)
    key_ok = redundant_data_for?(nameserver: false, input: data)

    return true if ns_ok && key_ok

    @logger.info "CsyncJob: #{domain}: Reseting state. Reason: " +
                 unqualification_reason(ns_ok, key_ok, result_types)

    CsyncRecord.where(domain: Domain.where(name: domain)).delete_all

    false
  end

  def redundant_data_for?(nameserver: false, input:)
    if nameserver
      input.size == 1 && (input & %w[secure insecure]).any?
    else
      input[:ns].map { |ns| ns[:cdnskey] }.uniq.size == 1
    end
  end

  def unqualification_reason(nss, key, result_types)
    return 'no CDNSKEY / nameservers reported different CDNSKEYs' unless key

    if result_types.include? 'untrustworthy'
      return 'current DNSSEC config invalid (required for rollover/delete)'
    end

    "Nameserver(s) not reachable / invalid data (#{result_types.join(', ')})" unless nss
  end

  def process_scanner_results
    scanner_results

    @results.keys.each do |domain|
      next unless qualified_for_monitoring?(domain, @results[domain])

      CsyncRecord.by_domain_name(domain)&.record_new_scan(@results[domain][:ns].first)
    end
  end

  def scanner_results
    scanner_line_results.each do |fetch|
      domain_name = fetch[:domain]
      @results[domain_name] = { ns: [] } unless @results[domain_name]
      @results[domain_name][:ns] << fetch.except(:domain)
    end
  end

  def scanner_line_results
    records = []
    File.open(ENV['cdns_scanner_output_file'], 'r').each_line do |line|
      # Input type, NS host, NS IP, Domain name, Key type, Protocol, Algorithm, Public key
      data = line.strip.split(' ')
      if data[0] == 'secure'
        type, domain, key_bit, proto, alg, pub, ns, ns_ip = data
      else
        type, ns, ns_ip, domain, key_bit, proto, alg, pub = data
      end
      cdnskey = key_bit && proto && alg && pub ? "#{key_bit} #{proto} #{alg} #{pub}" : nil
      record = { domain: domain, type: type, ns: ns, ns_ip: ns_ip, flags: key_bit, proto: proto,
                 alg: alg, pub: pub, cdnskey: cdnskey }
      records << record
    end
    records
  end

  # From this point we're working on generating input for cdnskey-scanner
  def gather_pollable_domains
    @logger.info 'CsyncJob Generate: Gathering current domain(s) data'
    Nameserver.select(:hostname, :domain_id).all.each do |ns|
      %i[secure insecure].each do |i|
        @input_store[i][ns.hostname] = [] unless @input_store[i].key? ns.hostname
      end

      append_domains_to_list(ns)
    end
  end

  def append_domains_to_list(nameserver)
    Domain.where(id: nameserver.domain_id).all.each do |domain|
      @input_store[domain.dnskeys.any? ? :secure : :insecure][nameserver.hostname].push domain.name
    end
  end

  def generate_scanner_input
    @logger.info 'CsyncJob Generate: Gathering current domain(s) data'
    gather_pollable_domains

    out_file = File.new(ENV['cdns_scanner_input_file'], 'w+')

    %i[secure insecure].each do |state|
      out_file.puts "[#{state}]"
      create_input_lines(out_file, state)
    end

    out_file.close
    @logger.info 'CsyncJob Generate: Finished writing output to ' + ENV['cdns_scanner_input_file']
  end

  def create_input_lines(out_file, state)
    @input_store[state].keys.each do |nameserver|
      domains = @input_store[state][nameserver].join(' ')
      next unless domains.length.positive?

      out_file.puts "#{nameserver} #{domains}"
    end
  end
end

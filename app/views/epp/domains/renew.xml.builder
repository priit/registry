xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:renData', 'xmlns:domain' => Xsd::Schema.filename(for_prefix: 'domain-ee')) do
        xml.tag!('domain:name', @domain[:name])
        xml.tag!('domain:exDate', @domain.valid_to.iso8601)
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end

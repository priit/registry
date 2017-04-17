require 'rails_helper'

RSpec.describe 'EPP domain:renew' do
  let(:request) { post '/epp/command/renew', frame: request_xml }
  let!(:user) { create(:api_user_epp, registrar: registrar) }
  let!(:registrar) { create(:registrar_with_unlimited_balance) }
  let!(:pricelist) { create(:pricelist,
                            category: 'com',
                            duration: '1year',
                            price: Money.from_amount(1),
                            operation_category: 'renew',
                            valid_from: Time.zone.parse('05.07.2010'),
                            valid_to: Time.zone.parse('05.07.2010'))
  }

  before :example do
    Setting.days_to_renew_domain_before_expire = 0
    travel_to Time.zone.parse('05.07.2010')
    sign_in_to_epp_area(user: user)
  end

  context 'when given expire time and current match' do
    let!(:domain) { create(:domain,
                           registrar: registrar,
                           name: 'test.com',
                           expire_time: Time.zone.parse('05.07.2010'))
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.com</domain:name>
              <domain:curExpDate>2010-07-05</domain:curExpDate>
              <domain:period unit="y">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'renews domain' do
      request
      domain.reload
      expect(domain.expire_time).to eq(Time.zone.parse('05.07.2011'))
    end

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end

  context 'when given expire time and current do not match' do
    let!(:domain) { create(:domain,
                           registrar: registrar,
                           name: 'test.com',
                           expire_time: Time.zone.parse('05.07.2010'))
    }
    let(:request_xml) { <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>test.com</domain:name>
              <domain:curExpDate>2010-07-04</domain:curExpDate>
              <domain:period unit="y">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML
    }

    it 'does not renew domain' do
      request
      domain.reload
      expect(domain.expire_time).to eq(Time.zone.parse('05.07.2010'))
    end

    specify do
      request
      expect(response).to have_code_of(2306)
    end
  end
end

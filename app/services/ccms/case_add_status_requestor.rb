module CCMS
  class CaseAddStatusRequestor < BaseRequestor
    wsdl_from 'ClientServiceWsdl.xml'.freeze

    uses_namespaces(
      'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
      'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header'
    )

    attr_reader :case_add_transaction_id

    def initialize(case_add_transaction_id)
      @case_add_transaction_id = case_add_transaction_id
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      soap_client.call(:get_case_txn_status, message: request_xml)
    end
    # :nocov:

    private

    def request_xml
      soap_envelope(namespaces).to_xml
    end

    def soap_body(xml)
      xml.__send__('ns2:CaseAddUpdtStatusRQ') do
        xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml) }
        xml.__send__('ns2:TransactionID', case_add_transaction_id)
      end
    end
  end
end

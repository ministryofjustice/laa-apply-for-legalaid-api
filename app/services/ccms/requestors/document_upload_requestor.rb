module CCMS
  module Requestors
    class DocumentUploadRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.documentServicesWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
        'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:ns4' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO'
      )

      attr_reader :case_ccms_reference, :ccms_document_id, :document_encoded_base64

      def initialize(case_ccms_reference, ccms_document_id, document_encoded_base64, provider_username, document_type = nil)
        super()
        @case_ccms_reference = case_ccms_reference
        @ccms_document_id = ccms_document_id
        @document_encoded_base64 = document_encoded_base64
        @provider_username = provider_username
        @document_type = document_type
      end

      def call
        soap_client.call(:upload_document, xml: request_xml)
      end

      private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__('ns2:DocumentUploadRQ') do
          xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('ns2:NotificationID', -1)
          xml.__send__('ns2:CaseReferenceNumber', case_ccms_reference)
          xml.__send__('ns2:Document') { document(xml) }
        end
      end

      def document(xml)
        xml.__send__('ns4:CCMSDocumentID', ccms_document_id)
        document_type(xml)
        xml.__send__('ns4:Channel', 'E')
        xml.__send__('ns4:BinData', document_encoded_base64)
      end

      def document_type(xml)
        case @document_type
        when 'bank_transaction_report'
          xml.__send__('ns4:DocumentType', 'BSTMT')
          xml.__send__('ns4:FileExtension', 'csv')
        when 'gateway_evidence_pdf'
          xml.__send__('ns4:DocumentType', 'STATE')
          xml.__send__('ns4:FileExtension', 'pdf')
        else
          xml.__send__('ns4:DocumentType', 'ADMIN1')
          xml.__send__('ns4:FileExtension', 'pdf')
        end
      end
    end
  end
end

require 'rails_helper'

module CCMS
  RSpec.describe ApplicantSearchResponseParser do
    describe 'parsing applicant search responses' do
      let(:no_results_response_xml) { ccms_data_from_file 'applicant_search_response_no_results.xml' }
      let(:one_result_response_xml) { ccms_data_from_file 'applicant_search_response_one_result.xml' }
      let(:multiple_results_response_xml) { ccms_data_from_file 'applicant_search_response_multiple_results.xml' }
      let(:parser) { described_class.new(Faker::Number.number(20), no_results_response_xml) }
      let(:expected_tx_id) { '20190301030405123456' }

      it 'raises if the transaction_request_ids dont match' do
        expect {
          parser.record_count
        }.to raise_error CCMS::CcmsError, 'Invalid transaction request id'
      end

      context 'there are no applicants returned' do
        let(:parser) { described_class.new(expected_tx_id, no_results_response_xml) }

        it 'extracts the number of records fetched' do
          expect(parser.record_count).to eq '0'
        end

        it 'does not return an applicant_ccms_reference' do
          expect(parser.applicant_ccms_reference).to be_nil
        end
      end

      context 'there is one applicant returned' do
        let(:parser) { described_class.new(expected_tx_id, one_result_response_xml) }

        it 'extracts the number of records fetched' do
          expect(parser.record_count).to eq '1'
        end

        it 'returns the applicant_ccms_reference' do
          expect(parser.applicant_ccms_reference).to eq '4390016'
        end
      end

      context 'there are multiple applicants returned' do
        let(:parser) { described_class.new(expected_tx_id, multiple_results_response_xml) }

        it 'extracts the number of records fetched' do
          expect(parser.record_count).to eq '2'
        end

        it 'returns the first applicant_ccms_reference' do
          expect(parser.applicant_ccms_reference).to eq '4390017'
        end
      end
    end
  end
end

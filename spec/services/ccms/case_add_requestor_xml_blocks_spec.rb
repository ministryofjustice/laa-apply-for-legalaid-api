require 'rails_helper'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe CaseAddRequestor do
    context 'XML request' do
      let(:expected_tx_id) { '201904011604570390059770666' }
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceeding_types,
               :with_everything,
               populate_vehicle: true,
               with_bank_accounts: 2
      end
      let(:respondent) { legal_aid_application.respondent }
      let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
      let(:requestor) { described_class.new(submission, {}) }
      let(:xml) { requestor.formatted_xml }
      before { allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id) }

      context 'DELEGATED_FUNCTIONS_DATE blocks' do
        context 'delegated functions used' do
          before do
            legal_aid_application.update(used_delegated_functions_on: Date.today, used_delegated_functions: true)
          end

          it 'generates the delegated functions block in the means assessment section' do
            block = XmlExtractor.call(xml, :global_means, 'DELEGATED_FUNCTIONS_DATE')
            expect(block).to be_present
            expect(block).to have_response_type('date')
            expect(block).to have_response_value(Date.today.strftime('%d-%m-%Y'))
          end

          it 'generates the delegated functions block in the merits assessment section' do
            block = XmlExtractor.call(xml, :global_merits, 'DELEGATED_FUNCTIONS_DATE')
            expect(block).to be_present
            expect(block).to have_response_type('date')
            expect(block).to have_response_value(Date.today.strftime('%d-%m-%Y'))
          end
        end

        context 'delegated functions not used' do
          it 'does not generate the delegated functions block in the means assessment section' do
            block = XmlExtractor.call(xml, :global_means, 'DELEGATED_FUNCTIONS_DATE')
            expect(block).not_to be_present
          end

          it 'does not generates the delegated functions block in the merits assessment section' do
            block = XmlExtractor.call(xml, :global_merits, 'DELEGATED_FUNCTIONS_DATE')
            expect(block).not_to be_present
          end
        end
      end

      context 'POLICE_NOTIFIED block' do
        context 'police notified' do
          before { respondent.update(police_notified: true) }
          it 'is true' do
            block = XmlExtractor.call(xml, :global_merits, 'POLICE_NOTIFIED')
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'true'
          end
        end

        context 'police NOT notified' do
          before { respondent.update(police_notified: false) }
          it 'is false' do
            block = XmlExtractor.call(xml, :global_merits, 'POLICE_NOTIFIED')
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'false'
          end
        end
      end

      context 'WARNING_LETTER_SENT & INJ_REASON_NO_WARNING_LETTER blocks' do
        context 'not sent' do
          before { respondent.update(warning_letter_sent: false) }
          it 'generates WARNING_LETTER_SENT block with false value' do
            block = XmlExtractor.call(xml, :global_merits, 'WARNING_LETTER_SENT')
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'false'
          end

          it 'generates INJ_REASON_NO_WARNING_LETTER block with reason' do
            block = XmlExtractor.call(xml, :global_merits, 'INJ_REASON_NO_WARNING_LETTER')
            expect(block).to be_present
            expect(block).to have_response_type 'text'
            expect(block).to have_response_value legal_aid_application.respondent.warning_letter_sent_details
          end
        end

        context 'sent' do
          it 'generates WARNING_LETTER_SENT block with true value' do
            respondent.update(warning_letter_sent: true)
            block = XmlExtractor.call(xml, :global_merits, 'WARNING_LETTER_SENT')
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'true'
          end

          it 'does not generates INJ_REASON_NO_WARNING_LETTER block' do
            respondent.update(warning_letter_sent: true)
            block = XmlExtractor.call(xml, :global_merits, 'INJ_REASON_NO_WARNING_LETTER')
            expect(block).not_to be_present
          end
        end
      end

      context 'INJ_RESPONDENT_CAPACITY' do
        context 'respondent has capacity' do
          before { respondent.understands_terms_of_court_order = true }
          it 'is true' do
            block = XmlExtractor.call(xml, :global_merits, 'INJ_RESPONDENT_CAPACITY')
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'true'
          end
        end

        context 'respondent does not have capacity' do
          before { respondent.understands_terms_of_court_order = false }
          it 'is false' do
            block = XmlExtractor.call(xml, :global_merits, 'INJ_RESPONDENT_CAPACITY')
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'false'
          end
        end
      end

      context 'PROC_MATTER_TYPE_MEANING' do
        it 'should be the meaning from the proceeding type record' do
          block = XmlExtractor.call(xml, :global_merits, 'PROC_MATTER_TYPE_MEANING')
          expect(block).to be_present
          expect(block).to have_response_type 'text'
          expect(block).to have_response_value legal_aid_application.proceeding_types.first.meaning
        end
      end

      context 'attributes hard coded to true' do
        it 'should be hard coded to true' do
          attributes = [
            [:global_means, 'LAR_SCOPE_FLAG'],
            [:global_means, 'GB_INPUT_B_38WP3_2SCREEN'],
            [:global_means, 'GB_INPUT_B_38WP3_3SCREEN'],
            [:global_merits, 'MERITS_DECLARATION_SCREEN'],
            [:global_means, 'GB_DECL_B_38WP3_13A'],
            [:global_merits, 'CLIENT_HAS_DV_RISK'],
            [:global_merits,  'CLIENT_REQ_SEP_REP'],
            [:global_merits,  'DECLARATION_WILL_BE_SIGNED'],
            [:global_merits,  'DECLARATION_REVOKE_IMP_SUBDP'],
            [:proceeding, 'SCOPE_LIMIT_IS_DEFAULT'],
            [:proceeding_merits,  'LEAD_PROCEEDING'],
            [:proceeding_merits,  'SCOPE_LIMIT_IS_DEFAULT']
          ]
          attributes.each do |entity_attribute_pair|
            entity, attribute = entity_attribute_pair
            block = XmlExtractor.call(xml, entity, attribute)
            expect(block).to be_present
            expect(block).to have_response_type 'boolean'
            expect(block).to have_response_value 'true'
          end
        end
      end
    end
  end
end

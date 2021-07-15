require 'rails_helper'

module Reports
  module BankTransactions
    RSpec.describe BankTransactionReportCreator do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceeding_types,
               :with_everything,
               :with_benefits_transactions,
               :with_uncategorised_credit_transactions,
               :with_cfe_v3_result,
               :generating_reports,
               ccms_submission: ccms_submission
      end
      let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

      let(:remarks) { CFE::Remarks.new(populated_remarks_hash) }
      let(:remarked_transaction) { double CFE::RemarkedTransaction, reasons: %i[amount_variation unknown_frequency] }
      before do
        allow(legal_aid_application.cfe_result).to receive(:remarks).and_return(remarks)
        allow(remarks.review_transactions.transactions).to receive(:[]).and_call_original
        allow(remarks.review_transactions.transactions).to receive(:[]).with(legal_aid_application.bank_transactions.first.id).and_return(remarked_transaction)
      end

      describe '.call' do
        context 'with no local_csv param' do
          subject { described_class.call(legal_aid_application) }

          it 'attaches bank_transaction_report.csv to the application' do
            subject
            legal_aid_application.reload
            expect(legal_aid_application.bank_transaction_report.document.content_type).to eq('text/csv')
            expect(legal_aid_application.bank_transaction_report.document.filename).to eq('bank_transaction_report.csv')
          end

          context 'report already exists' do
            it 'does not attach a report' do
              create :attachment, :bank_transaction_report, legal_aid_application: legal_aid_application
              expect { subject }.not_to change { Attachment.count }
            end
          end
        end

        context 'with local_csv param' do
          subject { creator.call(local_csv: true) }

          let(:creator) { BankTransactionReportCreator.new(legal_aid_application) }
          let(:tempfile) { Rails.root.join('tmp/bank_transactions.csv') }

          it 'creates a local file' do
            File.unlink(tempfile) if File.exist?(tempfile)
            subject
            expect(File.exist?(tempfile)).to be true
          end
        end
      end

      def populated_remarks_hash
        {
          state_benefit_payment: {
            amount_variation: %w[
              d55743b5-c1c4-4c9a-98a3-bad709aac422
              a277038a-86df-4bbd-8b87-d576ae150369
            ],
            unknown_frequency: %w[
              d55743b5-c1c4-4c9a-98a3-bad709aac422
              a277038a-86df-4bbd-8b87-d576ae150369
            ]
          },
          outgoings_housing_cost: {
            unknown_frequency: %w[
              5d58c3b1-c34d-4f20-90fc-c22642410cfa
              05bcd12c-6790-49bc-a1aa-490fba8d2624
            ]
          }
        }
      end
    end
  end
end

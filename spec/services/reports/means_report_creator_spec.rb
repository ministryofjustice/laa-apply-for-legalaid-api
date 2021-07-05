require 'rails_helper'

RSpec.describe Reports::MeansReportCreator do
  subject do
    # dont' match on path - webpacker keeps changing the second part of the path
    VCR.use_cassette('stylesheets2', match_requests_on: %i[method host headers]) do
      described_class.call(legal_aid_application)
    end
  end

  describe '.call' do
    context 'V3 CFE Result' do
      let(:legal_aid_application) do
        create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v3_result, :generating_reports, ccms_submission: ccms_submission
      end
      let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

      it 'attaches means_report.pdf to the application' do
        expect(Providers::MeansReportsController.renderer).to receive(:render).and_call_original
        subject
        legal_aid_application.reload
        expect(legal_aid_application.means_report.document.content_type).to eq('application/pdf')
        expect(legal_aid_application.means_report.document.filename).to eq('means_report.pdf')
      end

      it 'does not attach a report if one already exists' do
        create :attachment, :means_report, legal_aid_application: legal_aid_application
        expect { subject }.not_to change { Attachment.count }
      end

      context 'ccms case ref does not exist' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v3_result, :generating_reports, ccms_submission: ccms_submission
        end
        let(:ccms_submission) { create :ccms_submission }

        before do
          allow_any_instance_of(CCMS::Submission).to receive(:process!).with(any_args).and_return(true)
        end

        it 'processes the existing ccms submission' do
          expect(legal_aid_application.reload.ccms_submission).to receive(:process!)
          subject
        end
      end

      context 'ccms submission does not exist' do
        let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v3_result, :generating_reports }

        before do
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
          allow(legal_aid_application).to receive(:create_ccms_submission).and_return(ccms_submission)
        end

        after do
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
        end

        it 'creates a ccms submission' do
          expect(legal_aid_application.reload).to receive(:create_ccms_submission)
          expect(nil).to receive(:process!)
          subject
        end
      end
    end

    context 'V4 CFE result' do
      let(:legal_aid_application) do
        create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v4_result, :generating_reports, ccms_submission: ccms_submission
      end
      let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

      it 'attaches means_report.pdf to the application' do
        expect(Providers::MeansReportsController.renderer).to receive(:render).and_call_original
        subject
        legal_aid_application.reload
        expect(legal_aid_application.means_report.document.content_type).to eq('application/pdf')
        expect(legal_aid_application.means_report.document.filename).to eq('means_report.pdf')
      end

      it 'does not attach a report if one already exists' do
        create :attachment, :means_report, legal_aid_application: legal_aid_application
        expect { subject }.not_to change { Attachment.count }
      end

      context 'ccms case ref does not exist' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v4_result, :generating_reports, ccms_submission: ccms_submission
        end
        let(:ccms_submission) { create :ccms_submission }

        before do
          allow_any_instance_of(CCMS::Submission).to receive(:process!).with(any_args).and_return(true)
        end

        it 'processes the existing ccms submission' do
          expect(legal_aid_application.reload.ccms_submission).to receive(:process!)
          subject
        end
      end

      context 'ccms submission does not exist' do
        let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v4_result, :generating_reports }

        before do
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
          allow(legal_aid_application).to receive(:create_ccms_submission).and_return(ccms_submission)
        end

        after do
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
        end

        it 'creates a ccms submission' do
          expect(legal_aid_application.reload).to receive(:create_ccms_submission)
          expect(nil).to receive(:process!)
          subject
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Reports::MeritsReportCreator do
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_application_proceeding_type,
           :with_lead_proceeding_type,
           :with_everything,
           :generating_reports,
           ccms_submission: ccms_submission
  end
  let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

  subject do
    # dont' match on path - webpacker keeps changing the second part of the path
    VCR.use_cassette('stylesheets2', match_requests_on: %i[method host headers]) do
      described_class.call(legal_aid_application)
    end
  end

  describe '.call' do
    it 'attaches merits_report.pdf to the application' do
      expect(Providers::MeritsReportsController.renderer).to receive(:render).and_call_original
      subject
      legal_aid_application.reload
      expect(legal_aid_application.merits_report.document.content_type).to eq('application/pdf')
      expect(legal_aid_application.merits_report.document.filename).to eq('merits_report.pdf')
    end

    it 'does not attach a report if one already exists' do
      create :attachment, :merits_report, legal_aid_application: legal_aid_application
      expect { subject }.not_to change { Attachment.count }
    end

    context 'ccms case ref does not exist' do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_application_proceeding_type,
               :with_lead_proceeding_type,
               :with_everything,
               :generating_reports,
               ccms_submission: ccms_submission
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
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_application_proceeding_type,
               :with_lead_proceeding_type,
               :with_everything,
               :generating_reports
      end
      let(:ccms_submission) { create :ccms_submission }

      before do
        RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
        allow(legal_aid_application).to receive(:create_ccms_submission).and_return(ccms_submission)
        allow_any_instance_of(CCMS::Submission).to receive(:process!).with(any_args).and_return(true)
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

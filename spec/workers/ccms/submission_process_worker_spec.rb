require 'rails_helper'

RSpec.describe CCMS::SubmissionProcessWorker do
  let(:state) { :initialised }
  let(:submission) { create :submission, aasm_state: state }
  let(:worker) { described_class.new }

  before { allow(CCMS::Submission).to receive(:find).with(submission.id).and_return(submission) }

  subject { worker.perform(submission.id, state) }

  it 'calls process! on the submission' do
    expect(submission).to receive(:process!)
    subject
  end

  context 'worker retry count' do
    context 'when the retry is exceeding the max retries' do
      before do
        allow(submission).to receive(:process!).and_return(true)
        worker.retry_count = 20
      end

      it 'calls fail! on the submission' do
        expect(submission).to receive(:fail!)
        subject
      end
    end

    context 'when retry count is 6' do
      before do
        allow(submission).to receive(:process!).and_return(true)
        worker.retry_count = 6
      end

      it 'sends a sentry alert' do
        expect(Sentry).to receive(:capture_message).with(/^CCMS retrying this job submission_id: #{submission.id}  job stuck at state: initialised with retry count at 6/)
        subject
      end
    end

    context 'when retry count is less than the max' do
      before do
        allow(submission).to receive(:process!).and_return(true)
        worker.retry_count = 3
      end

      it 'calls process! on the submission' do
        expect(submission).to receive(:process!)
        subject
      end
    end
  end

  context 'the state has changed' do
    let(:submission) { create :submission, aasm_state: :initialised }
    let(:state) { :case_ref_obtained }

    it 'does nothing' do
      expect(submission).not_to receive(:process!)
      subject
    end
  end
end

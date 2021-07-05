module CCMS
  class SubmissionProcessWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
    attr_accessor :retry_count

    RETRY_COUNT = 10

    sidekiq_options retry: RETRY_COUNT

    def perform(submission_id, state)
      submission = Submission.find(submission_id)

      if @retry_count.to_i == 6
        Sentry.capture_message("CCMS retrying this job submission_id: #{submission.id}  job stuck at state: #{submission.aasm_state} with retry count at #{@retry_count}")
      elsif @retry_count.to_i >= RETRY_COUNT
        submission.fail!
        return
      end

      return unless submission.aasm_state == state.to_s # skip if state has already changed

      submission.process!

      return if submission.completed?

      # process next step
      SubmissionProcessWorker.perform_in(submission.delay, submission.id, submission.aasm_state)
    end
  end
end

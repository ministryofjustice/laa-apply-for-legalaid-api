require 'rails_helper'

RSpec.describe GovukEmails::EmailMonitor do
  include ActiveJob::TestHelper

  let(:arg_govuk_message_id) { SecureRandom.uuid }
  let(:status_govuk_message_id) { arg_govuk_message_id }
  let(:mailer) { 'FeedbackMailer' }
  let(:mail_method) { 'notify' }
  let(:delivery_method) { 'deliver_now!' }
  let(:feedback_email_params) { create :feedback }
  let(:to) { 'julien.sansot@digital.justice.gov.uk' }
  let(:email_args) { [feedback_email_params, to] }
  let(:message_status) { 'sending' }
  let!(:stub_send_email) do
    stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
      .to_return(status: 200, body: { id: status_govuk_message_id }.to_json)
  end
  let!(:stub_email_status) do
    stub_request(:get, "https://api.notifications.service.gov.uk/v2/notifications/#{status_govuk_message_id}")
      .to_return(status: 200, body: { status: message_status }.to_json)
  end
  let(:params) do
    {
      mailer: mailer,
      mail_method: mail_method,
      delivery_method: delivery_method,
      email_args: email_args,
      govuk_message_id: arg_govuk_message_id
    }
  end
  let(:email_monitor) { described_class.new(**params) }
  let(:time_now) { Time.zone.now }
  let(:double_email) do
    double(GovukEmails::Email,
           status: email_status,
           temp_or_perm_failed?: email_failed? || email_resend?,
           delivered?: email_delivered?)
  end
  let(:email_status) { 'sending' }
  let(:email_failed?) { false }
  let(:email_resend?) { false }
  let(:email_delivered?) { false }
  let(:mock_mailer) { double UndeliverableEmailAlertMailer, deliver_later!: nil }

  subject { email_monitor.call }

  describe '#call' do
    context 'email has not been sent yet' do
      let(:message_status) { 'sending' }
      let(:arg_govuk_message_id) { nil }
      let(:status_govuk_message_id) { SecureRandom.uuid }

      it 'sends the email' do
        subject
        expect(stub_send_email).to have_been_requested
      end

      it 'keeps monitoring the email' do
        expect(email_monitor).to receive(:trigger_job).with(status_govuk_message_id)
        subject
      end

      it 'does not send a new email' do
        expect(email_monitor).not_to receive(:trigger_job).with(nil)
        subject
      end

      it 'does not check its status now' do
        subject
        expect(stub_email_status).not_to have_been_requested
      end

      it 'has created an sent_email record' do
        subject
        sent_email = SentEmail.find_by!(govuk_message_id: status_govuk_message_id)
        expect(sent_email.mailer).to eq mailer
        expect(sent_email.addressee).to eq to
        expect(sent_email.mailer_args).to eq [feedback_email_params, to].to_json
        expect(sent_email.status).to eq 'created'
        expect(sent_email.status_checked_at).to be_nil
      end

      context 'unable to write the SentEmail record' do
        before { allow(SentEmail).to receive(:create!).and_raise(ActiveRecord::RecordInvalid) }
        it 'sends a message to Sentry' do
          expect(Raven).to receive(:capture_message).with(/Unable to write SentEmail record: ActiveRecord::RecordInvalid Record invalid/)
          subject
        end

        it 'still sends the email' do
          mailer = double(Mail::Message)
          govuk_notify_response = double(govuk_notify_response, id: 1234)
          expect(FeedbackMailer).to receive(:public_send).and_return(mailer)
          expect(mailer).to receive(:deliver_now!).and_return(mailer)
          expect(mailer).to receive(:govuk_notify_response).and_return(govuk_notify_response)
          allow(Raven).to receive(:capture_message)
          subject
        end
      end
    end

    context 'email has already been sent at least once' do
      context 'email has been delivered' do
        let!(:sent_email) { create :sent_email, :pending, govuk_message_id: arg_govuk_message_id }
        let(:message_status) { GovukEmails::Email::DELIVERED_STATUS }

        it 'does not send the email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'does not capture an exception' do
          expect(Raven).not_to receive(:capture_exception).with(message_contains(error_message))
          subject
        end

        it 'does not re-trigger the job for monitoring or sending a new email' do
          expect(email_monitor).not_to receive(:trigger_job)
          subject
        end

        it 'has updated the sent email record' do
          subject
          sent_email.reload
          expect(sent_email.status).to eq 'delivered'
        end
      end

      context 'email is still pending' do
        let!(:sent_email) { create :sent_email, :created, govuk_message_id: arg_govuk_message_id }
        let(:message_status) { 'pending' }

        it 'does not send the email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'does not capture an exception' do
          expect(Raven).not_to receive(:capture_exception).with(message_contains(error_message))
          subject
        end

        it 'keeps monitoring the email' do
          expect(email_monitor).to receive(:trigger_job).with(arg_govuk_message_id)
          subject
        end

        it 'does not send a new email' do
          expect(email_monitor).not_to receive(:trigger_job).with(nil)
          subject
        end

        it 'updates the sent_email record' do
          allow_any_instance_of(described_class).to receive(:email).and_return(double_email)
          travel_to time_now
          subject
          sent_email = SentEmail.find_by!(govuk_message_id: arg_govuk_message_id)
          expect(sent_email.status).to eq 'sending'
          expect(sent_email.status_checked_at.to_i).to eq time_now.to_i
          travel_back
        end
      end

      context 'email permanently failed' do
        let(:message_status) { GovukEmails::Email::PERMANENTLY_FAILED_STATUS }
        let(:email_status) { message_status }
        let!(:sent_email) { create :sent_email, :created, govuk_message_id: arg_govuk_message_id }

        it 'does not send the original email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'updates the sent_email record' do
          allow_any_instance_of(described_class).to receive(:email).and_return(double_email)
          travel_to time_now
          subject
          sent_email = SentEmail.find_by!(govuk_message_id: arg_govuk_message_id)
          expect(sent_email.status).to eq 'permanent-failure'
          expect(sent_email.status_checked_at.to_i).to eq time_now.to_i
          travel_back
        end

        it 'does not re-trigger the job for monitoring or sending a new email' do
          expect(email_monitor).not_to receive(:trigger_job)
          subject
        end

        context 'Rails configured to send undeliverable alerts' do
          before { allow(Rails.configuration.x).to receive(:alert_undeliverable_emails).and_return(true) }

          it 'sends an undeliverable email alert to team' do
            params = %w[
              julien.sansot@digital.justice.gov.uk
              permanent-failure
              FeedbackMailer
              notify
            ]
            expect(UndeliverableEmailAlertMailer).to receive(:notify_apply_team).with(*params).and_return(mock_mailer)
            subject
          end

          it 'sends a message to Sentry' do
            expect(Raven).to receive(:capture_message).with(/^Undeliverable Email Error -/)
            subject
          end
        end

        context 'Rails configured NOT to send undeliverable alerts' do
          before { allow(Rails.configuration.x).to receive(:alert_undeliverable_emails).and_return(false) }

          it 'does not send an undeliverable email alert to team' do
            expect(UndeliverableEmailAlertMailer).not_to receive(:notify_apply_team)
            subject
          end

          it 'sends a message to Sentry' do
            expect(Raven).not_to receive(:capture_message)
            subject
          end
        end
      end

      context 'email temporary failed' do
        let(:message_status) { GovukEmails::Email::RESENDABLE_STATUS.sample }
        let(:email_status) { message_status }
        let!(:sent_email) { create :sent_email, :created, govuk_message_id: arg_govuk_message_id }

        it 'does not send the original email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'updates the sent_email record' do
          allow_any_instance_of(described_class).to receive(:email).and_return(double_email)
          travel_to time_now
          subject
          sent_email = SentEmail.find_by!(govuk_message_id: arg_govuk_message_id)
          expect(sent_email.status).to eq message_status
          expect(sent_email.status_checked_at.to_i).to eq time_now.to_i
          travel_back
        end

        it 'does not re-trigger the job for monitoring or sending a new email' do
          expect(email_monitor).not_to receive(:trigger_job)
          subject
        end

        context 'Rails configured to send undeliverable alerts' do
          before { allow(Rails.configuration.x).to receive(:alert_undeliverable_emails).and_return(true) }

          it 'sends an undeliverable email alert to team' do
            params = [
              'julien.sansot@digital.justice.gov.uk',
              message_status,
              'FeedbackMailer',
              'notify'
            ]
            expect(UndeliverableEmailAlertMailer).to receive(:notify_apply_team).with(*params).and_return(mock_mailer)
            subject
          end

          it 'sends a message to Sentry' do
            expect(Raven).to receive(:capture_message).with(/^Undeliverable Email Error -/)
            subject
          end
        end

        context 'Rails configured NOT to send undeliverable alerts' do
          before { allow(Rails.configuration.x).to receive(:alert_undeliverable_emails).and_return(false) }

          it 'does not send an undeliverable email alert to team' do
            expect(UndeliverableEmailAlertMailer).not_to receive(:notify_apply_team)
            subject
          end

          it 'sends a message to Sentry' do
            expect(Raven).not_to receive(:capture_message)
            subject
          end
        end
      end
    end

    context "govuk_notify can't find email" do
      before do
        allow(Rails.configuration.x).to receive(:alert_undeliverable_emails).and_return(true)
        allow(GovukEmails::Email).to receive(:new).and_raise(Notifications::Client::NotFoundError, OpenStruct.new(code: 404, body: ''))
      end
      #   allow_any_instance_of(Notifications::Client)
      #     .to receive(:get_notification)
      #     .and_raise(Notifications::Client::NotFoundError, OpenStruct.new(code: 404, body: ''))
      # end

      let!(:sent_email) { create :sent_email, :created, govuk_message_id: arg_govuk_message_id }

      it 'raises an error' do
        allow(UndeliverableEmailAlertMailer).to receive(:notify_apply_team).and_return(mock_mailer)
        expect { subject }.to raise_error(Notifications::Client::NotFoundError)
      end

      it 'sends an undeliverable email alert' do
        params = %w[
          julien.sansot@digital.justice.gov.uk
          Notifications::Client::NotFoundError
          FeedbackMailer
          notify
        ]
        expect(UndeliverableEmailAlertMailer).to receive(:notify_apply_team).with(*params).and_return(mock_mailer)
        expect { subject }.to raise_error(Notifications::Client::NotFoundError)
      end

      it 'updates sent_email record' do
        expect { subject }.to raise_error(Notifications::Client::NotFoundError)
        sent_email = SentEmail.find_by!(govuk_message_id: arg_govuk_message_id)
        expect(sent_email.status).to eq 'Notifications::Client::NotFoundError'
      end

      context 'email is to simulated test email address' do
        let(:to) { Rails.configuration.x.simulated_email_address }

        it 'does not raise and error' do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe '#trigger_job' do
    let(:message_id) { SecureRandom.uuid }
    let(:enqueued_job) { enqueued_jobs.find { |job| job[:job] == GovukNotifyMailerJob } }

    it 'triggers the job to be sent in 5 seconds' do
      email_monitor.trigger_job(message_id)
      expect(Time.zone.at(enqueued_job[:at])).to be_within(2.seconds).of(Time.current + described_class::JOBS_DELAY)
    end

    it 'passes the correct parameters' do
      email_monitor.trigger_job(message_id)
      expect(GovukNotifyMailerJob).to(
        have_been_enqueued.with(mailer, mail_method, delivery_method, args: [feedback_email_params, to, { 'govuk_message_id' => message_id }])
      )
    end

    context 'without message_id' do
      let(:message_id) { nil }

      it 'passes the correct parameters' do
        email_monitor.trigger_job(message_id)
        expect(GovukNotifyMailerJob).to(
          have_been_enqueued.with(mailer, mail_method, delivery_method, args: [feedback_email_params, to])
        )
      end
    end
  end

  def error_message
    [
      '*Email ERROR*',
      "*#{mailer}.#{mail_method}* could not be sent",
      "*GovUk email status:* #{message_status}",
      email_args.to_s
    ].join("\n")
  end
end

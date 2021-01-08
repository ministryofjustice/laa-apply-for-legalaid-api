module Dashboard
  module WidgetDataProviders
    class Applications
      def self.dataset_definition
        {
          fields: [
            Geckoboard::DateField.new(:date, name: 'Date').to_hash,
            Geckoboard::NumberField.new(:started_apps, name: 'Started applications').to_hash,
            Geckoboard::NumberField.new(:submitted_apps, name: 'Submitted applications').to_hash,
            Geckoboard::NumberField.new(:submitted_passported_apps, name: 'Submitted passported applications').to_hash,
            Geckoboard::NumberField.new(:submitted_nonpassported_apps, name: 'Submitted nonpassported applications').to_hash,
            Geckoboard::NumberField.new(:total_submitted_apps, name: 'Total submitted applications').to_hash,
            Geckoboard::NumberField.new(:failed_apps, name: 'Failed applications').to_hash,
            Geckoboard::NumberField.new(:delegated_func_apps, name: 'Delegated function applications').to_hash
          ],
          unique_by: [:date]
        }
      end

      def self.data
        dates = (20.days.ago.to_date..Time.zone.today).to_a
        result_set = []
        dates.each do |date|
          result_set << metrics(date)
        end
        result_set
      end

      def self.handle
        'applications'
      end

      def self.format_date(date)
        date.strftime('%Y-%m-%d')
      end

      def self.metrics(date)
        {
          'date' => format_date(date),
          'started_apps' => started_applications(date),
          'submitted_apps' => submitted_applications(date),
          'total_submitted_apps' => total_submitted_applications(date),
          'submitted_passported_apps' => submitted_passported_apps(date),
          'submitted_nonpassported_apps' => submitted_nonpassported_apps(date),
          'failed_apps' => failed_ccms_submissions(date),
          'delegated_func_apps' => delegated_function_applications(date)
        }
      end

      def self.started_applications(date)
        LegalAidApplication.where('DATE(created_at) = ?', date).count
      end

      def self.total_submitted_applications(date)
        LegalAidApplication.where('DATE(merits_submitted_at) <= ?', date).count
      end

      def self.submitted_applications(date)
        submitted_applications_on(date).count
      end

      def self.submitted_passported_apps(date)
        submitted_applications_on(date).count(&:passported?)
      end

      def self.submitted_nonpassported_apps(date)
        submitted_applications_on(date).count(&:non_passported?)
      end

      def self.failed_ccms_submissions(date)
        CCMS::Submission.where('DATE(created_at) = ? AND aasm_state = ?', date, 'failed').count
      end

      def self.delegated_function_applications(date)
        ApplicationProceedingType
          .where.not(used_delegated_functions_on: [nil])
          .where('DATE(created_at) = ?', date)
          .uniq(&:legal_aid_application_id).count
      end

      def self.submitted_applications_on(date)
        LegalAidApplication.where('DATE(merits_submitted_at) = ?', date)
      end

      private_class_method :submitted_applications_on
    end
  end
end

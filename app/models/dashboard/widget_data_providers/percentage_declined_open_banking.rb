# Percentage of citizens that have denied open banking consent
#
module Dashboard
  module WidgetDataProviders
    class PercentageDeclinedOpenBanking
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:declined_open_banking, name: 'Percentage that declined open banking consent').to_hash
          ]
        }
      end

      def self.data
        percentage_declining_consent = declined_consent / total_consent_answers * 100
        [
          {
            'declined_open_banking' => percentage_declining_consent
          }
        ]
      end

      def self.handle
        'declined_open_banking'
      end

      def self.declined_consent
        LegalAidApplication.where('open_banking_consent=false').count.to_f
      end

      def self.total_consent_answers
        LegalAidApplication.count(:open_banking_consent).to_f
      end
    end
  end
end

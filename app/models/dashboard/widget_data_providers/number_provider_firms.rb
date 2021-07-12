# count the number of provider firms that have ever logged in
#
module Dashboard
  module WidgetDataProviders
    class NumberProviderFirms
      def self.dataset_definition
        {
          fields: [
            Geckoboard::NumberField.new(:number, name: 'Firms').to_hash
          ]
        }
      end

      def self.data
        provider_count = Provider.all.group(:firm_id).count.size
        [
          {
            'number' => provider_count
          }
        ]
      end

      def self.handle
        'number_provider_firms'
      end
    end
  end
end

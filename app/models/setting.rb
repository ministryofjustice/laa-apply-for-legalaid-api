class Setting < ApplicationRecord
  def self.mock_true_layer_data?
    setting.mock_true_layer_data?
  end

  def self.allow_non_passported_route?
    return false unless Rails.configuration.x.allow_non_passported_route

    setting.allow_non_passported_route?
  end

  def self.setting
    Setting.first || Setting.create!
  end
end

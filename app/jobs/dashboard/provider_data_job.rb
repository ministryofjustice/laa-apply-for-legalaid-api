module Dashboard
  class ProviderDataJob < ActiveJob::Base
    include SuspendableJob

    def perform(provider)
      return if job_suspended?

      Dashboard::SingleObject::ProviderData.new(provider).run
    end
  end
end

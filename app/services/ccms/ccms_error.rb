module CCMS
  CCMSError = Class.new(StandardError)
  class CCMSUnsuccessfulResponseError < StandardError
    attr_reader :response

    def initialize(response)
      super
      @response = response
    end
  end
end

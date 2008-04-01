module AuthenticatedSpecHelper
  class RequireLogin
    def initialize(example)
      @example = example
    end

    def response
      @example.response
    end 
    def request
      @example.request
    end

    def login_url(*options)
      @example.controller.__send__(:login_url, *options)
    end
    
    def matches?(target)
      @target = target
      @target.call
      response.redirect? && response.redirect_url == login_url#(:redirect => request.request_uri)
    end

    def failure_message
      "expected #{response.redirect_url} to be #{login_url}"#(:redirect => request.request_uri)}"
    end
  end

  def require_login
    RequireLogin.new(self)
  end
end

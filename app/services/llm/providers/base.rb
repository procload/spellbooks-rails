module LLM
  module Providers
    class Base
      def initialize(config)
        @config = config
      end

      def generate_completion(prompt, **options)
        raise NotImplementedError, "#{self.class} must implement #generate_completion"
      end

      protected

      def handle_error(error)
        case error
        when Faraday::TimeoutError
          raise LLM::TimeoutError, "Request timed out"
        when Faraday::ClientError
          if error.response[:status] == 401
            raise LLM::AuthenticationError, "Invalid API key"
          else
            raise LLM::APIError, "API request failed: #{error.response[:body]}"
          end
        else
          raise LLM::Error, "Unexpected error: #{error.message}"
        end
      end
    end
  end
end

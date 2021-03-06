# frozen_string_literal: true

# use Snowpack::Instrumentation::Rack::Appsignal, {
#   sample: 0.2,
#   filters: {
#     "/some/exact/route"   => 0.05,    # <- custom sample rate (5%) for specific URL
#     %r{/another/.+/route} => false,   # <- do not instrument this URL, n.b. match via Regexp
#   },
# }

require "appsignal"
require_relative "appsignal_ext"
require "rack"
require "securerandom"

module Snowpack
  module Instrumentation
    module Appsignal
      class Rack
        attr_reader :app, :options

        def initialize(app, **options)
          @app = app
          @options = options
        end

        def call(env)
          if ::Appsignal.active?
            call_with_appsignal_monitoring(env)
          else
            app.call(env)
          end
        end

        private

        def call_with_appsignal_monitoring(env)
          request = ::Rack::Request.new(env)

          transaction = ::Appsignal::Transaction.create(
            SecureRandom.uuid,
            ::Appsignal::Transaction::HTTP_REQUEST,
            request,
          )

          transaction.discard! unless sample?(request)

          begin
            ::Appsignal.instrument "process_action.generic" do
              app.call(env)
            end
          rescue Exception => error
            transaction.set_error(error)
            raise error
          ensure
            if env["appsignal.route"]
              transaction.set_action_if_nil(env["appsignal.route"])
            else
              transaction.set_action_if_nil("unknown")
            end

            transaction.set_metadata("path", request.path)
            transaction.set_metadata("method", request.request_method)

            transaction.set_http_or_background_queue_start
            ::Appsignal::Transaction.complete_current!
          end
        end

        def sample?(request)
          rate = options.fetch(:sample, 1)

          options.fetch(:filters, {}).each do |match, sample|
            rate = sample and break if request.path.match?(match)
          end

          rate = 1 if rate == true

          rate && rand <= rate
        end
      end
    end
  end
end

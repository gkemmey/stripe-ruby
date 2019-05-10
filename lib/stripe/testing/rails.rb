require "stripe/testing/mock_api"

class ActiveSupport::TestCase
  setup do
    Stripe::MockAPI.start
    Stripe.api_base = "http://localhost:#{Stripe::MockAPI.current_session.server_port}"
  end
end

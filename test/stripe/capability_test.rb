# frozen_string_literal: true

require ::File.expand_path("../../test_helper", __FILE__)

module Stripe
  class CapabilityTest < Test::Unit::TestCase
    context "#resource_url" do
      should "return a resource URL" do
        capability = Stripe::Capability.construct_from(
          id: "acap_123",
          account: "acct_123"
        )
        assert_equal "/v1/accounts/acct_123/capabilities/acap_123",
                     capability.resource_url
      end

      should "raise without an account" do
        capability = Stripe::Capability.construct_from(id: "acap_123")
        assert_raises NotImplementedError do
          capability.resource_url
        end
      end
    end

    should "raise on #retrieve" do
      assert_raises NotImplementedError do
        Stripe::Capability.retrieve("acap_123")
      end
    end

    should "raise on #update" do
      assert_raises NotImplementedError do
        Stripe::Capability.update("acap_123", {})
      end
    end

    should "be saveable" do
      account = Stripe::Account.retrieve("acct_123")
      capability = account.retrieve_capability("acap_123")
      capability.requested = true
      capability.save
      assert_requested :post,
                       "#{Stripe.api_base}/v1/accounts/#{capability.account}/capabilities/#{capability.id}"
    end
  end
end

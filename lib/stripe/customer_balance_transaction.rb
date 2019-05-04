# frozen_string_literal: true

module Stripe
  class CustomerBalanceTransaction < APIResource
    OBJECT_NAME = "customer_balance_transaction".freeze

    def resource_url
      if !respond_to?(:customer) || customer.nil?
        raise NotImplementedError,
              "Customer Balance Transactions cannot be accessed without a customer ID."
      end
      "#{Customer.resource_url}/#{CGI.escape(customer)}/customer_balance_transactions/#{CGI.escape(id)}"
    end

    def self.retrieve(_id, _opts = {})
      raise NotImplementedError,
            "Customer Balance Transactions cannot be retrieved without a customer ID. " \
            "Retrieve a Customer Balance Transaction using Customer.retrieve_customer_balance_transaction('cus_123', 'cbtxn_123')"
    end
  end
end

require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "専用ページのトークンから顧客を引ける" do
    customer = customers(:yamada)
    assert_equal customer, Customer.find_by_portal_token(customer.portal_token)
  end

  test "改ざんしたトークンでは引けない" do
    assert_nil Customer.find_by_portal_token(customers(:yamada).portal_token + "x")
    assert_nil Customer.find_by_portal_token(customers(:yamada).id)
  end
end

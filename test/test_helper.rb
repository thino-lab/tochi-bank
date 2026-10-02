ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

module SignInHelper
  def sign_in(profile, password: "password")
    post login_path, params: { email: profile.email, password: password }
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end

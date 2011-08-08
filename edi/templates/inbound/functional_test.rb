require File.expand_path("<%= test_helper_path %>", __FILE__)

module <%= namespace.modulize %>
  class <%= class_name %> < ActionController::TestCase
    def setup
      @user = login
    end

    should "test something" do
      assert fail
    end

  end
end

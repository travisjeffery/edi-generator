require File.expand_path("<%= test_helper_path %>", __FILE__)

module Api::Edi::Belvika::Hershey::Sap
  class <%= class_name %>Test < ActiveSupport::TestCase

    setup do
      @edi = <%= class_name %>.make!
    end

    should "have edi" do
      assert @edi
    end

    should "have a source" do
      assert fail
    end

    should "create edi log" do
      assert fail
    end

    should "have a dropdown name" do
      assert fail
    end

    should "have a label name" do
      assert fail
    end

  end
end

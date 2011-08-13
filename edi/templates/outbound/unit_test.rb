require File.expand_path("<%= test_helper_path %>", __FILE__)

module Api::Edi::Belvika::Hershey::Sap
  class <%= class_name %>Test < ActiveSupport::TestCase

    setup do
      @edi = <%= class_name %>.make!
    end

    should "have edi" do
      assert @edi
    end

<% if edi_source %>
     should "have <%= edi_source %> as source" do
       assert_equal <%= edi_source.classify %>, @edi.source
     end

    should "have dropdown name" do
      assert_equal "EDI <%= edi_code %>", @edi.dropdown_name
    end

    should "have label name" do
      assert_equal "<%= edi_source.titleize %> -> EDI <%= edi_code %>", @edi.label_name
    end

    should "have view model" do
      assert_equal "<%= edi_source.pluralize %>", @edi.class.view_model
    end
<% else %>
    should "have a source" do
      assert fail
    end

    should "have a dropdown name" do
      assert fail
    end

    should "have a label name" do
      assert fail
    end
<% 

    should "create edi log" do
      assert fail
    end

  end
end

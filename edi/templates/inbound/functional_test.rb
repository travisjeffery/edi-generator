require File.expand_path("<%= test_helper_path %>", __FILE__)

class %= namespace.modulize %>::<%= controller_name.camelize %>Test < ActiveSupport::TestCase

  def setup 
    @edi_xml = nil
    @edi = <%= class_name %>.make! :request_xml => @edi_xml
  end 

  should "test something" do 
    assert fail
  end 

  should "successfully create with valid xml" do
    assert fail
  end

  should "not create with invalid xml" do
    assert fail
  end

  should "not create when the workflow is disabled" do
    assert fail
  end
end

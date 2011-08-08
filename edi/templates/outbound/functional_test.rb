require File.expand_path("<%= test_helper_path %>", __FILE__)
require 'nokogiri'

module <%= namespace.modulize %>
  class <%= class_name %>Test < ActiveSupport::TestCase

    def setup 
      @edi_xml = nil
      @edi = <%= class_name %>.make! :request_xml => @edi_xml
    end 

    should "test something" do 
      assert fail
    end 

  end
end

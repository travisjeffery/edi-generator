require File.expand_path("<%= test_helper_path %>", __FILE__)
require 'nokogiri'

module <%= namespace.modulize %>
  class <%= controller_name.camelize %>Test < ActiveSupport::TestCase

    def setup 
      login

      @edi = <%= class_name %>.make!
      @edi.make_queued
    end 

    context "index" do
      should "return successfully" do
        get :index

        assert_response :success
      end
    end

    context "update" do
      should "return successfully" do
        put :update, :id => @edi.id, :format => :xml

        assert_response :success

        assert_equal EdiOutbound::SENT, @edi.reload.status
        assert @edi.payload
      end

      should "test structure" do
        assert fail
      end

    end
  end
end

require File.expand_path('../../../../../../../test_helper', __FILE__)
require 'nokogiri'

class <%= namespace.modulize %>::Edi944ControllerTest < ActionController::TestCase

  def setup 
    login 

    @edi = <%= class_name %>.make!
    @edi.make_queued
  end

  test "should get index" do
    get :index

    assert_response :success

    assert fail
  end

  context "update" do
    should "return successfully" do
      put :update, :id => @edi.id, :format => :xml

      assert_response :success

      assert_equal EdiOutbound::SENT, @edi.reload.status
      assert @edi.payload

      assert fail
    end
  end
end

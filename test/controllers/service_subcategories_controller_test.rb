require 'test_helper'

class ServiceSubcategoriesControllerTest < ActionController::TestCase
  setup do
    @service_subcategory = service_subcategories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_subcategories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_subcategory" do
    assert_difference('ServiceSubcategory.count') do
      post :create, service_subcategory: {  }
    end

    assert_redirected_to service_subcategory_path(assigns(:service_subcategory))
  end

  test "should show service_subcategory" do
    get :show, id: @service_subcategory
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_subcategory
    assert_response :success
  end

  test "should update service_subcategory" do
    patch :update, id: @service_subcategory, service_subcategory: {  }
    assert_redirected_to service_subcategory_path(assigns(:service_subcategory))
  end

  test "should destroy service_subcategory" do
    assert_difference('ServiceSubcategory.count', -1) do
      delete :destroy, id: @service_subcategory
    end

    assert_redirected_to service_subcategories_path
  end
end

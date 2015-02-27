require_relative 'test_helper'

class RedirectController < ActionController::Base
  def redirect_to_url_string
    redirect_to 'http://example.com'
  end

  def redirect_to_url_string_with_turbolinks
    redirect_to 'http://example.com', turbolinks: true
  end

  def redirect_to_url_hash
    redirect_to action: 'action'
  end

  def redirect_to_url_hash_with_turbolinks
    redirect_to({action: 'action'}, turbolinks: true)
  end

  def redirect_to_path_and_custom_status
    redirect_to '/path', status: 303
  end

  def redirect_to_path_with_single_change_option
    redirect_to '/path', change: 'foo'
  end

  def redirect_to_path_with_multiple_change_option
    redirect_to '/path', change: ['foo', :bar]
  end

  def redirect_to_path_with_change_option_and_custom_status
    redirect_to '/path', change: ['foo', :bar], status: 303
  end

  def redirect_to_path_with_turbolinks_and_single_keep_option
    redirect_to '/path', turbolinks: true, keep: 'foo'
  end

  def redirect_to_path_with_turbolinks_and_multiple_keep_option
    redirect_to '/path', turbolinks: true, keep: ['foo', :bar]
  end
end

class RedirectionTest < ActionController::TestCase
  tests RedirectController

  def test_redirect_to_url_string_with_turbolinks
    get :redirect_to_url_string_with_turbolinks
    assert_turbolinks_visit 'http://example.com'
  end

  def test_redirect_to_url_hash_with_turbolinks
    get :redirect_to_url_hash_with_turbolinks
    assert_turbolinks_visit 'http://test.host/redirect/action'
  end

  def test_redirect_to_url_string_via_xhr_and_post_redirects_via_turbolinks
    xhr :post, :redirect_to_url_string
    assert_turbolinks_visit 'http://example.com'
  end

  def test_redirect_to_url_hash_via_xhr_and_patch_redirects_via_turbolinks
    xhr :patch, :redirect_to_url_hash
    assert_turbolinks_visit 'http://test.host/redirect/action'
  end

  def test_redirect_to_path_and_custom_status_via_xhr_and_delete_redirects_via_turbolinks
    xhr :delete, :redirect_to_path_and_custom_status
    assert_turbolinks_visit 'http://test.host/path'
  end

  def test_redirect_to_via_xhr_and_get_does_normal_redirect
    xhr :get, :redirect_to_path_and_custom_status
    assert_response 303
    assert_redirected_to 'http://test.host/path'
  end

  def test_redirect_to_via_post_and_not_xhr_does_normal_redirect
    post :redirect_to_url_hash
    assert_redirected_to 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_patch_and_not_xhr_does_normal_redirect
    patch :redirect_to_url_string
    assert_redirected_to 'http://example.com'
  end

  def test_redirect_to_via_xhr_and_post_with_single_change_option
    xhr :post, :redirect_to_path_with_single_change_option
    assert_turbolinks_visit 'http://test.host/path', "{ change: ['foo'] }"
  end

  def test_redirect_to_via_xhr_and_post_with_multiple_change_option
    xhr :post, :redirect_to_path_with_multiple_change_option
    assert_turbolinks_visit 'http://test.host/path', "{ change: ['foo', 'bar'] }"
  end

  def test_redirect_to_via_xhr_and_post_with_change_option_and_custom_status
    xhr :post, :redirect_to_path_with_change_option_and_custom_status
    assert_turbolinks_visit 'http://test.host/path', "{ change: ['foo', 'bar'] }"
  end

  def test_redirect_to_via_xhr_and_get_with_change_option
    xhr :get, :redirect_to_path_with_multiple_change_option
    assert_redirected_to 'http://test.host/path'
  end

  def test_redirect_to_via_post_and_not_xhr_with_change_option_and_custom_status
    post :redirect_to_path_with_change_option_and_custom_status
    assert_response 303
    assert_redirected_to 'http://test.host/path'
  end

  def test_redirect_to_with_turbolinks_and_single_keep_option
    get :redirect_to_path_with_turbolinks_and_single_keep_option
    assert_turbolinks_visit 'http://test.host/path', "{ keep: ['foo'] }"
  end

  def test_redirect_to_with_turbolinks_and_multiple_keep_option
    get :redirect_to_path_with_turbolinks_and_multiple_keep_option
    assert_turbolinks_visit 'http://test.host/path', "{ keep: ['foo', 'bar'] }"
  end

  def test_redirect_to_with_change_and_keep_raises_argument_error
    assert_raises ArgumentError do
      @controller.redirect_to '/path', change: :foo, keep: :bar
    end
  end

  private

  def assert_turbolinks_visit(url, change = nil)
    change = ", #{change}" if change
    assert_response 200
    assert_equal "Turbolinks.visit('#{url}'#{change});", @response.body
    assert_equal 'text/javascript', @response.content_type
  end
end

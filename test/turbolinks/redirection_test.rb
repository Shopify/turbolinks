require_relative 'test_helper'

class RedirectController < ActionController::Base
  def redirect_via_turbolinks_to_url_string
    redirect_via_turbolinks_to 'http://example.com'
  end

  def redirect_via_turbolinks_to_url_hash
    redirect_via_turbolinks_to action: 'action'
  end

  def redirect_via_turbolinks_to_path_and_custom_status
    redirect_via_turbolinks_to '/path', status: 303
  end

  def redirect_via_turbolinks_to_path_with_single_change_option
    redirect_via_turbolinks_to '/path', change: 'foo'
  end

  def redirect_via_turbolinks_to_path_with_multiple_change_option
    redirect_via_turbolinks_to '/path', change: ['foo', :bar]
  end

  def simple_redirect
    redirect_to action: 'action'
  end

  def simple_redirect_with_single_change_option
    redirect_to({action: 'action'}, change: 'foo')
  end

  def simple_redirect_with_multiple_change_option
    redirect_to({action: 'action'}, change: ['foo', :bar])
  end
end

class RedirectionTest < ActionController::TestCase
  tests RedirectController

  def test_redirect_to_via_xhr_and_post_redirects_via_turbolinks
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
    post :simple_redirect
    assert_turbolinks_visit 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_xhr_and_patch_redirects_via_turbolinks
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
    patch :simple_redirect
    assert_turbolinks_visit 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_xhr_and_get_does_normal_redirect
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
    get :simple_redirect
    assert_redirected_to 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_post_and_not_xhr_does_normal_redirect
    post :simple_redirect
    assert_redirected_to 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_patch_and_not_xhr_does_normal_redirect
    patch :simple_redirect
    assert_redirected_to 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_xhr_and_post_with_single_change_option
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
    post :simple_redirect_with_single_change_option
    assert_turbolinks_visit 'http://test.host/redirect/action', "{ change: ['foo'] }"
  end

  def test_redirect_to_via_xhr_and_post_with_multiple_change_option
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
    post :simple_redirect_with_multiple_change_option
    assert_turbolinks_visit 'http://test.host/redirect/action', "{ change: ['foo', 'bar'] }"
  end

  def test_redirect_to_via_post_and_not_xhr_with_single_change_option
    post :simple_redirect_with_single_change_option
    assert_redirected_to 'http://test.host/redirect/action'
  end

  def test_redirect_to_via_xhr_and_get_with_multiple_change_option
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
    get :simple_redirect_with_multiple_change_option
    assert_redirected_to 'http://test.host/redirect/action'
  end

  def test_redirect_via_turbolinks_to_url_string
    get :redirect_via_turbolinks_to_url_string
    assert_turbolinks_visit 'http://example.com'
  end

  def test_redirect_via_turbolinks_to_url_hash
    get :redirect_via_turbolinks_to_url_hash
    assert_turbolinks_visit 'http://test.host/redirect/action'
  end

  def test_redirect_via_turbolinks_to_path_and_custom_status
    get :redirect_via_turbolinks_to_path_and_custom_status
    assert_turbolinks_visit 'http://test.host/path'
  end

  def test_redirect_via_turbolinks_to_path_with_single_change_option
    get :redirect_via_turbolinks_to_path_with_single_change_option
    assert_turbolinks_visit 'http://test.host/path', "{ change: ['foo'] }"
  end

  def test_redirect_via_turbolinks_to_path_with_multiple_change_option
    get :redirect_via_turbolinks_to_path_with_multiple_change_option
    assert_turbolinks_visit 'http://test.host/path', "{ change: ['foo', 'bar'] }"
  end

  private

  def assert_turbolinks_visit(url, change = nil)
    change = ", #{change}" if change
    assert_response 200
    assert_equal "Turbolinks.visit('#{url}'#{change});", @response.body
    assert_equal 'text/javascript', @response.content_type
  end
end

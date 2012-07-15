
require File.expand_path("../../lib/spreadshirt_client", __FILE__)
require "test/unit"

class SpreadshirtClientTest < Test::Unit::TestCase
  def setup
    SpreadshirtClient.api_key = "test"
    SpreadshirtClient.api_secret = "test"
  end

  def test_api_key
    assert_nothing_raised { SpreadshirtClient.api_key }
  end

  def test_api_secret
    assert_nothing_raised { SpreadshirtClient.api_secret }
  end

  def test_base_url
    assert_equal "http://api.spreadshirt.net/api/v1", SpreadshirtClient.base_url

    SpreadshirtClient.base_url = "http://test.spreadshirt.net/api/v1"

    assert_equal "http://api.spreadshirt.net/api/v1", SpreadshirtClient.base_url

    SpreadshirtClient.base_url = "http://api.spreadshirt.net/api/v1"
  end

  def test_authorize
    regex = /\ASprdAuth apiKey=\"test\", data=\"post http:\/\/api.spreadshirt.net\/api\/v1\/baskets\/1\/items [0-9]+\", sig=\"[0-9a-f]{40}\"\Z/

    assert SpreadshirtClient.authorize(:post, "/baskets/1/items") =~ regex
  end

  def test_authorize_with_session
    regex = /\ASprdAuth apiKey=\"test\", data=\"post http:\/\/api.spreadshirt.net\/api\/v1\/orders [0-9]+\", sig=\"[0-9a-f]{40}\", sessionId=\"abcd-1234\"\Z/

    assert SpreadshirtClient.authorize(:post, "/orders", "abcd-1234") =~ regex
  end

  def test_url_for
    assert_equal "http://api.spreadshirt.net/api/v1/basket/1/items", SpreadshirtClient.url_for("/basket/1/items")
    assert_equal "http://test.spreadshirt.net/api/v1/basket/1/items", SpreadshirtClient.url_for("http://test.spreadshirt.net/api/v1/basket/1/items")
  end

  def test_headers_for
    headers = SpreadshirtClient.headers_for(:post, "/basket/1/items", :authorization => true, :session => "abcd-1234")

    assert_equal [:authorization], headers.keys

    assert headers[:authorization].include?("SprdAuth")
    assert headers[:authorization].include?("abcd-1234")

    assert_equal({ :params => { :limit => 500 } }, SpreadshirtClient.headers_for(:get, "/shops/1/articles", :params => { :limit => 500 }))
  end

  def test_method_for
    assert_equal "POST", SpreadshirtClient.method_for(:post)
  end

  def test_put
    # Can't be tested.
  end

  def test_post
    # Can't be tested.
  end

  def test_get
    # Can't be tested.
  end

  def test_delete
    # Can't be tested.
  end
end



require File.expand_path("../../lib/spreadshirt_client", __FILE__)
require "minitest"
require "minitest/autorun"
require "mocha/mini_test"

class SpreadshirtClient::TestCase < MiniTest::Test
  def assert_nothing_raised
    yield
  end
end

class SpreadshirtClientTest < SpreadshirtClient::TestCase
  def setup
    SpreadshirtClient.api_key = "test"
    SpreadshirtClient.api_secret = "test"

    Time.expects(:now).returns(Time.utc(2012, 1, 1)).at_least(0)
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

    assert_equal "http://test.spreadshirt.net/api/v1", SpreadshirtClient.base_url

    SpreadshirtClient.base_url = "http://api.spreadshirt.net/api/v1"
  end

  def test_authorize
    assert_equal 'SprdAuth apiKey="test", data="post http://api.spreadshirt.net/api/v1/baskets/1/items 1325376000", sig="932555fa9cc0854b03473487af521045dc12d3d0"', SpreadshirtClient.authorize(:post, "/baskets/1/items")
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

    assert_equal [:authorization, :content_type], headers.keys

    assert headers[:authorization].include?("SprdAuth")
    assert headers[:authorization].include?("abcd-1234")

    assert_equal({ :params => { :limit => 500 }, :content_type => "application/xml" }, SpreadshirtClient.headers_for(:get, "/shops/1/articles", :params => { :limit => 500 }))
  end

  def test_method_for
    assert_equal "POST", SpreadshirtClient.method_for(:post)
  end

  def test_timeout
    assert_equal 30, SpreadshirtClient.timeout

    SpreadshirtClient.timeout = 5

    assert_equal 5, SpreadshirtClient.timeout

    SpreadshirtClient.timeout = 30
  end

  def test_put
    RestClient.expects(:put).with("http://api.spreadshirt.net/api/v1/baskets/1/items/1", "payload", :authorization => 'SprdAuth apiKey="test", data="PUT http://api.spreadshirt.net/api/v1/baskets/1/items/1 1325376000", sig="2f7a28edc68bbec83a8a580bbd1506ba9192f68e"', :content_type => "application/xml").returns(200)

    assert_equal 200, SpreadshirtClient.put("/baskets/1/items/1", "payload", :authorization => true)
  end

  def test_post
    RestClient.expects(:post).with("http://api.spreadshirt.net/api/v1/baskets", "payload", :authorization => 'SprdAuth apiKey="test", data="POST http://api.spreadshirt.net/api/v1/baskets 1325376000", sig="04097ac87eadc5d6d0766b2dabf509ebc35eb3bc"', :content_type => "application/xml").returns(200)

    assert_equal 200, SpreadshirtClient.post("/baskets", "payload", :authorization => true)
  end

  def test_get
    RestClient.expects(:get).with("http://api.spreadshirt.net/api/v1/orders/1", :authorization => 'SprdAuth apiKey="test", data="GET http://api.spreadshirt.net/api/v1/orders/1 1325376000", sig="7f06c7604b97b682c545262bd9acbbaf04eb8fcd", sessionId="abcd-1234"', :content_type => "application/xml").returns(200)

    assert_equal 200, SpreadshirtClient.get("/orders/1", :authorization => true, :session => "abcd-1234")
  end

  def test_delete
    RestClient.expects(:delete).with("http://api.spreadshirt.net/api/v1/baskets/1/items/1", :authorization => 'SprdAuth apiKey="test", data="DELETE http://api.spreadshirt.net/api/v1/baskets/1/items/1 1325376000", sig="010f76d9c0a01278872a897b72bcac4daf0109cf"', :content_type => "application/xml").returns(200)

    assert_equal 200, SpreadshirtClient.delete("/baskets/1/items/1", :authorization => true)
  end
end


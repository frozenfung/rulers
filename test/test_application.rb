require_relative "test_helper"

class TestApp < Rulers::Application
end

class RulersAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  # Exercise 3
  def test_request
    get "/"

    assert last_response.ok?
    body = last_response.body
    assert body ["Hello"]
  end

  # Extra exercise
  def sunglasses
    post "/sunglasses"

    assert_equal last_response.status, 200
    assert last_response.header['Content-Type'], 'text/html'
    assert last_response.body, '😎'
  end
end

require_relative "test_helper"

module Rulers
  class Controller
    def render(view_name, locals = {})
      `echo "I am view. Variable <%= foo %>" > test.rb`
      template = File.read 'test.rb'
      `rm test.rb`
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(env: env))
    end
  end
end

class TestController < Rulers::Controller
  def index
    render 'test.rb', { foo: "Hello" }
  end
end

class TestApp < Rulers::Application
  def get_controller_and_action(env)
    [TestController, "index"]
  end
end

class RulersAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  def test_request
    get "/example/route"

    assert last_response.ok?
    body = last_response.body
    assert body ["Hello"]
  end
end

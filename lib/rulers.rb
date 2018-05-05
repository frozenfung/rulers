require "rulers/version"
require "rulers/util"
require "rulers/routing"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"
require "rulers/sqlite_model"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico' || env['PATH_INFO'] == 'robots.txt'
        return [404, {'Content-Type' => 'text/html'}, []]
      end

      klass, act = get_controller_and_action(env)
      controller = klass.new(env)
      text = controller.send(act)
      [200, {'Content-Type' => 'text/html'}, [text]]
    end
  end
end

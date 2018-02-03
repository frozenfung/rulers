module Rulers
  class Controller
    def initialize(env)
      @env = env
    end

    def env
      @env
    end

    def render(view_name, locals = {})
      filename = File.join "app", "views", controller_name ,"#{view_name}.html.erb"
      template = File.read filename

      eruby = Erubis::Eruby.new(template)
      instance_variables = self.instance_variables.map { |v| [v, self.instance_variable_get(v)] }
      eruby.result(locals.merge(env: env).merge(instance_variables.to_h))
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, "")
      Rulers.to_underscore klass
    end
  end
end
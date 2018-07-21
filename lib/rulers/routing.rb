class RouteObject
  def initialize
    @rules = []
  end

  def match(url, *args)
    options = {}
    options = args.pop if args[-1].is_a?(Hash)
    options[:default] ||= {}

    dest = nil
    dest = args.pop if args.size > 0
    raise "Too many args!" if args.size > 0

    parts = url.split('/')
    # url: "quotes/show"
    # parts: ["quotes", "show"]
    parts.select! { |p| !p.empty? }

    vars = []
    regexp_parts = parts.map do |part|
      if part[0] == ":"
        vars << part[1..-1]
        "([a-zA-Z0-9]+)"
      elsif part[0] == "*"
        vars << part[1..-1]
        "(.*)"
      else
        part
      end
    end

    regexp = regexp_parts.join("/")
    @rules.push({
      :regexp => Regexp.new("^/#{regexp}$"),
      :vars => vars,
      :dest => dest,
      :options => options,
    })
  end

  def check_url(url)
    puts '------------------'
    puts url
    puts '------------------'
    @rules.each do |r|
      m = r[:regexp].match(url)

      if m
        options = r[:options]
        params = options[:default].dup
        r[:vars].each_with_index do |v, i|
          params[v] = m.captures[i]
        end

        if r[:dest]
          return get_dest(r[:dest], params)
        else
          controller = params["controller"]
          action = params["action"]
          return get_dest("#{controller}"+"##{action}", params)
        end
      end
    end
  end

  def get_dest(dest, routing_params = {})
    return dest if dest.respond_to?(:call)
    if dest =~ /^([^#]+)#([^#]+)$/
      name = $1.capitalize
      cont = Object.const_get("#{name}Controller")
      return cont.action($2, routing_params)
      raise "No destination: #{dest.inspect}!"
    end
  end
end

module Rulers
  class Application
    def route(&block)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      raise "No routes!" unless @route_obj
      @route_obj.check_url env["PATH_INFO"]
    end

    def get_controller_and_action(env)
      _, cont, action, after = env["PATH_INFO"].split("/", 4)

      if cont.empty?
        return [Object.const_get("QuotesController"), "base_quote"]
      else
        cont = cont.capitalize + "Controller"
      end

      [Object.const_get(cont), action]
    end
  end
end

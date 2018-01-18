module Rulers
  class Application
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

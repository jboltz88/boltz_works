module BoltzWorks
  class Application
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"
      controller = Object.const_get(controller)
      controller_inst = controller.new(env)
      [200, {'Content-Type' => 'text/html'}, [controller_inst.send(action)]]
    end

    def fav_icon(env)
      if env["PATH_INFO"] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end
  end
end

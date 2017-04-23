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

    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end
      app = @router.look_up_url(env["PATH_INFO"], env["REQUEST_METHOD"])
      app
    end
  end

  class Router
    def initialize
      @rules = []
    end

    # builds route/action rules and add them to @rules
    def map(url, *args)
      options, destination = map_args_result(*args)
      vars, regex = map_url_result(url)

      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: vars, destination: destination,
                    options: options })
    end

    # puts together options and destination for route map
    def map_args_result(*args)
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0

      return options, destination
    end

    # puts together vars and regex for route map
    def map_url_result(url)
      parts = url.split("/")
      parts.reject! { |part| part.empty? }

      vars, regex_parts = [], []
      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end

      regex = regex_parts.join("/")
      return vars, regex
    end

    def look_up_url(url, request)
      @rules.each do |rule|
        if request.downcase == rule[:options][:default]["request_method"].downcase
          rule_match = rule[:regex].match(url)
        end

        if rule_match
          return set_variables(rule, rule_match)
        end
      end

      proc { |env| [404, { "Content-Type" => "text/html" }, ["Not Found"]] }
    end

    def set_variables(rule, rule_match)
      options = rule[:options]
      params = options[:default].dup

      rule[:vars].each_with_index do |var, index|
        params[var] = rule_match.captures[index]
      end

      if rule[:destination]
        return get_destination(rule[:destination], params)
      else
        controller = params["controller"]
        action = params["action"]
        return get_destination("#{controller}##{action}", params)
      end
    end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        return destination
      end

      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end

    def resources(controller)
      map "#{controller}", default: {"controller" => controller, "action" => "index", "request_method" => "get"}
      map "#{controller}/index", default: {"controller" => controller, "action" => "index", "request_method" => "get"}
      map "#{controller}", default: {"controller" => controller, "action" => "create", "request_method" => "post"}
      map "#{controller}/new", default: {"controller" => controller, "action" => "new", "request_method" => "get"}
      map "#{controller}/:id/edit", default: {"controller" => controller, "action" => "edit", "request_method" => "get"}
      map "#{controller}/:id", default: {"controller" => controller, "action" => "show", "request_method" => "get"}
      map "#{controller}/:id", default: {"controller" => controller, "action" => "update", "request_method" => "put"}
      map "#{controller}/:id", default: {"controller" => controller, "action" => "destroy", "request_method" => "delete"}
    end

  end
end

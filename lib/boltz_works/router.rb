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
  end

  class Router
    def initialize
      @rules = []
    end

    # builds route/action rules and add them to @rules
    def map(url, *args)
      puts "url: #{url}"
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}
      puts "options: #{options}"

      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0
      puts "destination: #{destination}"

      parts = url.split("/")
      parts.reject! { |part| part.empty? }

      vars, regex_parts = [], []

      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          puts ": vars => #{vars}"
          regex_parts << "([a-zA-Z0-9]+)"
          puts ": regex => #{regex_parts}"
        when "*"
          vars << part[1..-1]
          puts "* vars => #{vars}"
          regex_parts << "(.*)"
          puts "* regex => #{regex_parts}"
        else
          regex_parts << part
          puts "default regex => #{regex_parts}"
        end
      end

      regex = regex_parts.join("/")
      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: vars, destination: destination,
                    options: options })
    end
  end
end

require "erubis"

module BoltzWorks
  class Controller
    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      puts "in dispatch, action: #{action}, routing_params: #{routing_params}"
      @routing_params = routing_params
      text = self.send(action)
      puts "in dispatch, text: #{text}"
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(action, response = {})
      puts "in self.action, action: #{action} response: #{response}"
      proc { |env| self.new(env).dispatch(action, response) }
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params.merge(@routing_params)
    end

    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def render(*args)
      if args.empty?
        args << @routing_params["action"]
      end
      puts "args: #{args}"
      response(create_response_array(*args))
    end

    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)

      self.instance_variables.each do |instance_var|
        instance_var_value = self.instance_variable_get(instance_var)
        eruby.instance_variable_set(instance_var, instance_var_value)
      end

      eruby.result(locals.merge(env: @env))
    end

    # convert a string like BooksController to books
    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BoltzWorks.snake_case(klass)
    end


    def redirect_to(location, status="302", routing_params={})
      puts "in redirect_to, location: #{location}, routing_params: #{routing_params}"
      if status == "302"
        # handles actions that exist for the controller that calls the redirect
				if self.respond_to? location
					routing_params['controller'] = self.class.to_s.split('Controller')[0].downcase
					routing_params['action'] = location.to_s
					dispatch(location, routing_params)
        # handles urls or routes outside of the application
        else
					response("", "302", {"Location" => location})
				end
			else
				puts "Incorrect status code supplied for redirect"
			end
    end
  end
end

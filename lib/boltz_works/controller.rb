require "erubis"

module BoltzWorks
  class Controller
    def initialize(env)
      @env = env
    end

    def render(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)

      self.instance_variables.each do |instance_var|
        instance_var_value = self.instance_variable_get(instance_var)
        eruby.instance_variable_set(instance_var, instance_var_value)
      end

      eruby.result(locals.merge(env: @env))
    end

    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BoltzWorks.snake_case(klass)
    end
  end
end

require "boltz_works/version"
require "boltz_works/utility"
require "boltz_works/dependencies"
require "boltz_works/router"
require "boltz_works/controller"

module BoltzWorks
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end

      rack_app = get_rack_app(env)
      rack_app.call(env)
    end
  end
end

require "boltz_works/version"
require "boltz_works/utility"
require "boltz_works/dependencies"
require "boltz_works/router"
require "boltz_works/controller"

module BoltzWorks
  class Application
    def call(env)
      [200, {'Content-Type' => 'text/html'}, ["Hello!"]]
    end
  end
end

require "boltz_works/version"

module BoltzWorks
  class Application
    def call(env)
      [200, {'Content-Type' => 'text/html'}, ["Hello!"]]
    end
  end
end

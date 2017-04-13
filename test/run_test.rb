base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir  = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test")
controller_dir = File.join(test_dir, "controllers")

$LOAD_PATH.unshift(lib_dir)
$LOAD_PATH.unshift(controller_dir)

require 'test/unit'
require 'rack/test'
require 'boltz_works'

class TestBoltzWorks < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BoltzWorks::Application.new
  end

  def test_it_routes_to_actions
    get "/test/welcome"

    assert_equal(200, last_response.status)
    assert_equal("testing", last_response.body)
  end

  def test_it_routes_to_favicon
    get "/favicon.ico"
    assert_equal(404, last_response.status)
  end

end

# exit Test::Unit::AutoRunner.run(true, test_dir)

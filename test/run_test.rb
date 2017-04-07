base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir  = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test")

$LOAD_PATH.unshift(lib_dir)

require 'test/unit'
require 'rack/test'

class CallTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BoltzWorks::Application.new
  end

  def test_call
    # authorize "bryan", "secret"
    # get "/"
    # #follow_redirect!
    #
    # assert_equal "http://example.org/redirected", last_request.url
    assert last_response.ok?
  end

end

exit Test::Unit::AutoRunner.run(true, test_dir)

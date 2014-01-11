require_relative 'spec_helper.rb'

class AppTest < MiniTest::Spec
  include Rack::Test::Methods

  register_spec_type(/.+$/, self)

  def app
    HtmlCompilerApp
  end

  def is_valid?(html)
    html.strip!
    return ! (html.nil? || html.empty? || html.include?('Undefined') || html.include?('Invalid'))
  end

  describe "Routes" do
    describe "GET / with a disallowed referer" do
      before do
        # using the rack::test:methods, call into the sinatra app and request the following url
        get "/", '', rack_env={'HTTP_ORIGIN' => 'http://invalid.test', 'referer' => 'http://invalid.test'}
      end

      it "responds with server error" do
        # Ensure the request we just made gives us a  status code
        last_response.status.must_equal 403
      end
    end
    

    inputs = {
      'Haml' => "%h1 Test",
      'Markdown' => "# Test",
      'Textile' => "h1. Test",
      'HTML' => "<h1>Test</h1>"
    }

    inputs.each do |syntax, sample|
      describe "POST / with #{syntax} input" do
        before do
          post '/', {input: sample, syntax: syntax}, rack_env={'HTTP_ORIGIN' => 'http://test.sassmeister.dev'}
        end

        it "responds with HTML" do
          last_response.body.strip.must_equal '<h1>Test</h1>'
        end
      end
    end

  end
end

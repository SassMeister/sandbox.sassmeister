require './app'

# Gzip responses
use Rack::Deflater

# Run the application
run HtmlCompilerApp

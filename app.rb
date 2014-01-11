$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'rubygems'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra/base'
require 'json'

require 'html/pipeline'
require 'RedCloth'
require 'haml'
# require 'slim'
require 'uri'

require './lib/html/pipeline/haml.rb'

# require 'pry-remote'

class HtmlCompilerApp < Sinatra::Base
  set :protection, :except => :frame_options

  configure :production do
    require 'newrelic_rpm'
  end


  helpers do
    def render_html(html, filter)
      context = {
        :gfm => true
      }

      if filter == 'Textile'
        filter = HTML::Pipeline::TextileFilter

      elsif filter == 'Haml'
        filter = HTML::Pipeline::HamlFilter

      else
        filter = HTML::Pipeline::MarkdownFilter
      end

      output = HTML::Pipeline.new([filter], context).call(html)[:output]

      return output.to_html if output.respond_to?(:to_html)

      return output.to_s
    end

    def origin
      return request.env["HTTP_ORIGIN"] if origin_allowed? request.env["HTTP_ORIGIN"]

      uri = URI.parse(request.referer)
      referer =  URI.parse('')
      referer.scheme = uri.scheme
      referer.host = uri.host

      return referer.to_s if origin_allowed? referer.to_s

      return false
    end

    def origin_allowed?(uri)
      return false if uri.nil?

      return uri.match(/^http:\/\/(.+\.){0,1}sassmeister\.(com|dev|([\d+\.]{4}xip\.io))/)
    end
  end

  before do
    params[:syntax].downcase! unless params[:syntax].nil?

    headers 'Access-Control-Allow-Origin' => origin if origin
  end

  get '/' do
    erb :render, :layout => false
  end

  post '/' do
    case params[:syntax]
    when 'haml'
        return render_html(params[:input], 'Haml')

    when 'markdown'
        return render_html(params[:input], 'Markdown')

    when 'textile'
        return render_html(params[:input], 'Textile')

    else
      return params[:input]
    end
  end

  run! if app_file == $0
end

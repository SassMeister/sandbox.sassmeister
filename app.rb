$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'rubygems'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra/base'
require 'json'

require 'html/pipeline'
require 'RedCloth'
require 'haml'
require 'slim'

require './lib/html/pipeline/haml.rb'

# require 'pry-remote'

class SassMeisterCompilerApp < Sinatra::Base
  set :protection, :except => :frame_options

  configure :production do
    APP_DOMAIN = 'sassmeister.com'
    require 'newrelic_rpm'
  end

  configure :development do
    APP_DOMAIN = 'sassmeister.dev'
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

      pipe = HTML::Pipeline.new [filter], context

      pipe.call(html)[:output].to_html
    end
  end


  before do
    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?
    params[:html_syntax].downcase! unless params[:html_syntax].nil?

    headers 'Access-Control-Allow-Origin' => "http://#{APP_DOMAIN}"
  end

  get '/' do
    erb :render, :layout => false
  end

  post '/' do
    case params[:html_syntax]
    when 'haml'
        return render_html(params[:html], 'Haml')

    when 'markdown'
        return render_html(params[:html], 'Markdown')

    when 'textile'
        return render_html(params[:html], 'Textile')

    else
      return params[:html]
    end
  end

  run! if app_file == $0
end
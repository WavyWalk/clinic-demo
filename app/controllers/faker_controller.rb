require 'net/http'
require 'http'
require 'uri'

class FakerController < ApplicationController

  def home
    # res = Rails.cache.fetch('foo') do
    #   "asd"
    # end

    # render inline: res
    if should_prerender?
      run_prerender
      return
    end

    if current_user
      @current_user = current_user.as_json(only: [:id, :email, :registered], roles: current_user.general_roles_as_json)
    else
      @current_user = nil
    end

  end
          

  def console
   raise "hello there!"   
  end

  def test

    PrerenderSitemapJob.perform_later

    render plain: 'enqueued'
     
  end

  def test_prerender
    
    # def fetch(uri_str, limit = 10)
    #   # You should choose a better exception.
    #   raise ArgumentError, 'too many HTTP redirects' if limit == 0

    #   response = Net::HTTP.get_response(URI(uri_str))

    #   case response
    #   when Net::HTTPSuccess then
    #     response
    #   when Net::HTTPRedirection then
    #     location = response['location']
    #     warn "redirected to #{location}"
    #     fetch(location, limit - 1)
    #   else
    #     response.value
    #   end
    # end

    # x = fetch('http://localhost:8888/')
    
    # response = 
    #   HTTP
    #     .headers()
    #     .get('http://www.pikabu.ru')


    render inline: request.headers.to_h.to_s

  end

  def not_found
    head 404
  end

  def restricted_asset
    if current_user
      send_file Rails.root + "app/assets/javascripts/foo.js.rb", type: "application/javascript"
    else
      head 403
    end
  end

  def should_prerender?
    request.env["HTTP_USER_AGENT"] =~ /bot/i
  end

  def run_prerender
    
    #Timeout::timeout(10) do

      prerender and return

    #end

  rescue Timeout::Error
    head 503 and return

  end

  def prerender

    # @enqueued ||= true
    # unless @enqueued
    #   queue_prerender_request
    # end 
    
    @retries ||= -1
    @retries += 1

    # if prerender_busy?
    #   retry_prerender
    # else
    #   make_prerender_request
    # end and return

    make_prerender_request and return

    # rescue Timeout::Error => e
    #   head 503

    # ensure
    #   @dequeued ||= true
    #   unless @dequeued
    #     unqueue_prerender_request
    #   end
  end

  # def retry_prerender
  #   if @retries > 1
  #     head 503 
  #   else
  #     sleep 2
  #     prerender
  #   end
  # end

  # def prerender_busy?
  #   current_requests_count = Rails.cache.read('pending_requests_to_prerender').to_i
  #   current_requests_count > 7
  # end

  # def queue_prerender_request
  #   current_requests_count = Rails.cache.read('pending_requests_to_prerender').to_i
  #   Rails.cache.write('pending_requests_to_prerender', (current_requests_count += 1))
  # end

  # def unqueue_prerender_request
  #   current_requests_count = Rails.cache.read('pending_requests_to_prerender').to_i
  #   Rails.cache.write('pending_requests_to_prerender', (current_requests_count -= 1))
  # end

  def make_prerender_request

    request_fullpath = request.fullpath

    precached_response = Rails.cache.read(request_fullpath)

    if precached_response
    
      case precached_response[0..3]
      when '500'
        head 503 and return
      when '404'
        head 404 and return
      else
        render html: precached_response.html_safe, layout: false and return
      end
    
    else

      #render plain: 'no cache' and return

      response_to_prerender = 
        HTTP
          .timeout(:per_operation, :write => 50, :connect => 50, :read => 50)
          .get('http://localhost:8888' + request_fullpath)

      if response_to_prerender.code == 503

        head 503

      else
        
        response_body = response_to_prerender.body.to_s

        if response_body.length < 40
          head 503
        else
          render html: response_body.html_safe, layout: false
        end
      end

    end

    rescue HTTP::ConnectionError, HTTP::TimeoutError

      head 503

  end

end
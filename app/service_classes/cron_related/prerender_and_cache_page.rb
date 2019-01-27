require 'net/http'
require 'http'
require 'uri'
require 'zlib'


class CronRelated::PrerenderAndCachePage

  def self.cache_pages_from_sitemaps
    
    File.open("#{Rails.root}/public/system/sitemap.xml.gz", 'rb') do |f|
      gz = Zlib::GzipReader.new(f)
      sitemap = Nokogiri::XML(gz.read)

      
      sitemap.css('loc').each do |loc|
      
        uri = URI::parse(loc.content)
        fullpath = "#{uri.path}#{uri.query}"
        fullpath = fullpath.blank? ? '/' : fullpath
        
        puts "path: #{fullpath}"

        CronRelated::PrerenderAndCachePage.for_path(fullpath)
        sleep 0.5
      
      end
      
      gz.close
    
    end
  end

  def self.for_path(path)
    
    self.new(path)

  end

  def initialize(path)
    @path = path
    init
  end

  def init
    make_prerender_request
    write_response_to_cache
  end


  def make_prerender_request
    puts "#{Time.now}: making req"
    @response = 
      HTTP
        .timeout(:per_operation, :write => 3, :connect => 3, :read => 10)
        .get('http://localhost:8888' + @path)

    resolve_response

    rescue HTTP::ConnectionError, HTTP::TimeoutError

      @response_to_write_in_cache = false
      puts 'con timeout'

  end

  def resolve_response
    
    if @response.code == 404
      @response_to_write_in_cache = '404' 
    elsif @response.code == 500
      @response_to_write_in_cache = '503'
    elsif @response.code == 200
      @response_to_write_in_cache = @response.body.to_s
    end
    puts "resolving at #{Time.now}"
    puts "response is: #{@response.body.to_s[0..40]}"
  end


  def write_response_to_cache
    
    if @response_to_write_in_cache
      Rails.cache.write(@path, @response_to_write_in_cache)
      @succeded = true
    else
      @succeded = false
    end

  end

  def succeded?
    @succeded
  end



end





class PrerenderSitemapJob < ActiveJob::Base
  
  queue_as :default

  def perform
    CronRelated::PrerenderAndCachePage.cache_pages_from_sitemaps
  end

end

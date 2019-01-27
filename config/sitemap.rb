SitemapGenerator.verbose = false
SitemapGenerator::Sitemap.sitemaps_path = 'system/'
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.abcstomastana.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  add '/contacts'
  
  add '/offered_services'

  add '/price_list'

  add '/blogs'

  add '/appointments/index'

  Blog.where(published: true).select(:id, :slug, :published_at).find_each do |blog|
    add "/blogs/#{blog.slug}", lastmod: blog.published_at
  end

  add '/personnel'

  User.joins(:roles).where('roles.name = ?', 'doctor').select(:id).find_each do |doctor|
    add "/personnel/#{doctor.id}"
  end

  OfferedService.select(:id, :slug, :updated_at).find_each do |offered_service|
    add "/offered_services/#{offered_service.slug}", lastmod: offered_service.updated_at
  end

end

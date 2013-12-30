class Result
  attr_reader :new_urls, :urls

  def initialize(status, urls, new_urls)
    @status = status
    @urls = urls
    @new_urls = new_urls
  end

  def good?
    @status == :good
  end

  def bad?
    @status == :bad
  end

  def add_url(url)
    @urls << url
  end

  def self.bad(url)
    Result.new(:bad, [url], [])
  end

  def self.good(url, new_urls)
    same_host_new_urls = get_same_host_urls(new_urls, url)
    Result.new(:good, [url], same_host_new_urls)
  end

  def self.get_same_host_urls(new_links, main_link)
    new_urls = new_links.compact.map do |link| 
      begin
        URI(link) 
      rescue
      end
    end.compact
    main_url = URI(main_link)
    no_host_urls = new_urls.select { |url| url.host == nil }
    same_host_urls = new_urls.select { |url| url.host == main_url.host }
    fixed_urls = no_host_urls.map do |url|
      URI.join(main_link,url.to_s)
    end.reject do |url|
      url.host == nil
    end
    (same_host_urls + fixed_urls).map(&:to_s)
  end

end



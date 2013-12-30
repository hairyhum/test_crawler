class LinkExtractor
  def self.get_links(body)
    Nokogiri::HTML::parse(body).css('a').map { |el| el['href'] }
  end
end  

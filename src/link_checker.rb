require 'result'
require 'link_extractor'

class LinkChecker 
 
  def self.redirect_limit
    @redirect_limit || 3
  end
  
  def self.redirect_limit=(limit)
    @redirect_limit = limit
  end

  def self.client
    @client || HTTPClient.new
  end

  def self.check(link)
    puts "GET #{link}"
    begin 
      response = client.get_content(link)
      Result::good(link, LinkExtractor::get_links(response))
    rescue HTTPClient::BadResponseError => err
      Result::bad(link)
    rescue Errno::ECONNREFUSED => err
      Result::bad(link)
    rescue SocketError => err
      Result::bad(link)
    end
    
  end
end



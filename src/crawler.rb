require 'net/http'
require 'nokogiri'
require 'httpclient'
require 'link_checker'

class Crawler
  attr_writer :thread_limit
  def self.thread_limit
    @thread_limit || 20
  end
  def self.thread_limit=(limit)
    @thread_limit = limit
  end

  def self.crawl(url)
    pending_links = [url]
    good_links = []
    bad_links = []
    until pending_links.empty?
      to_check = pending_links.take(thread_limit)
      pending_links = pending_links.drop(thread_limit)
      workers = create_workers(to_check)
      workers_result = get_workers_result(workers)
      
      new_links = workers_result[:new]
      bad_results = workers_result[:bad]
      good_results = workers_result[:good]
      
      good_links += good_results
      bad_links += bad_results
      pending_links += new_links

      good_links.uniq!
      bad_links.uniq!
      pending_links.uniq!

      pending_links = (pending_links.uniq - bad_links.uniq) - good_links
    end
    { :good => good_links, :bad => bad_links }
  end

  def self.create_workers(links_to_check)
    links_to_check.map do |link|
      Thread::new { || LinkChecker::check(link) }
    end
  end

  def self.get_workers_result(workers) 
    res = workers.inject({:good => [], :bad => [], :new => []}) do |all_result, worker|
      worker_result = worker.value
      if worker_result.good?
        all_result.merge({
          :good => all_result[:good] + worker_result.urls,
          :new => all_result[:new] + worker_result.new_urls
        })
      else
        all_result.merge({
          :bad => all_result[:bad] += worker_result.urls
        })
      end
    end
    workers.each(&:kill)
    res
  end

end



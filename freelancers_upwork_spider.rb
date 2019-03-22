require 'kimurai'

class FreelancersUpworkSpider < Kimurai::Base
  @name = "freelancers_upwork_spider"
  @engine = :selenium_chrome
  @start_urls = ['https://www.upwork.com/o/profiles/users/_~011a01a8c2fb9edf2a/']
  @config = {
  user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  before_request: { delay: 4..7 }
  }

  def parse(response, url:, data: {})

    freelancer = {}

    top_rated = response.xpath("//span[@class='badge badge-top-rated ng-scope'][contains(text(),'Top rated')]").present?
    verified = response.xpath("//span[@class='idv-verified badge badge-verified ng-scope']//span[@class='glyphicon air-icon-verified']").present?
    ph_verified = response.xpath("//div[@data-ng-if='/$ctrl.profile.phoneVerified']").present?
    jss = response.css(".m-0-bottom.ng-binding").first.text
    total_earned = response.css('.cfe-aggregates li.ng-scope h3 > span.ng-binding').text
    available = response.at_css('.m-0-top-bottom.d-none.d-md-block.ng-scope > span.ng-binding').text
    response = response.css('.cfe-sidebar .p-0-top-bottom.up-active-container.ng-scope > div.ng-scope span.ng-binding').text

    freelancer[:url] = url
    freelancer[:top_rated] = top_rated
    freelancer[:verified] = verified
    freelancer[:ph_verified] = ph_verified
    freelancer[:jss] = jss
    freelancer[:total_earned] = total_earned
    freelancer[:available] = available
    freelancer[:response] = response

    puts freelancer

    save_to 'scraped_freelancer.json', freelancer, format: :pretty_json

    # puts "JSS #{response.css(".m-0-bottom.ng-binding").first.text}"
    # puts "Verified: #{verified}"
    # puts "Top rated: #{top_rated}"
    # puts "Phone Verified: #{ph_verified}"
    # puts "Total earned: #{response.css('.cfe-aggregates li.ng-scope h3 > span.ng-binding').text}"
    # puts "Available: #{response.at_css('.m-0-top-bottom.d-none.d-md-block.ng-scope > span.ng-binding').text}"
    # puts "Response: #{response.css('.cfe-sidebar .p-0-top-bottom.up-active-container.ng-scope > div.ng-scope span.ng-binding').text}"
  end
end

PagesUpworkSpider.crawl!

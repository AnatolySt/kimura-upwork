require 'kimurai'
require 'two_captcha'

class LinksUpworkSpider < Kimurai::Base
  @name = "links_upwork_spider"
  @engine = :selenium_firefox
  @start_urls = ['https://www.upwork.com/o/profiles/browse/']
  @config = {
  user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  # proxy: -> { "138.197.102.119:80" },
  window_size: [1920, 1080],
  before_request: { delay: 3..5, clear_cookies: false }
  }

  @@client = TwoCaptcha.new('') # здесь должен быть ключ (брать в профиле 2captcha.com или rucaptcha.com)
  @@counter = 1

  def parse(response, url:, data: {})
    freelancers_links = Array.new

    while (@@counter <= 5) do
      sleep(rand(2..4))

      browser.save_and_open_page
      if response.css('.page-title > h1').text == 'Please verify you are a human'
        recaptcha_key = browser.find(:xpath, "//div[@class='g-recaptcha']")['data-sitekey']
        # token = browser.find(:css, "input[id='recaptcha-token']", visible: false)['value']
        solved = solve_recaptcha(recaptcha_key, url)
        puts "Solved key: #{solved}"
        # browser.find(:css, "textarea[id='g-recaptcha-response']", visible: false).set("#{solved}")
        puts "Executing scripts to resolve captcha"
        browser.execute_script("document.getElementById('g-recaptcha-response').value = '#{solved}';")
        browser.execute_script("handleCaptcha();")
        sleep(rand(4..7))
        browser.save_and_open_page
        browser.save_and_open_screenshot
      end

      response.xpath("//h4[@class='m-0-top-bottom display-inline-block']//a[@class='freelancer-tile-name']").each do |freelancer_link|
        freelancers_links.push(freelancer_link[:href]) if freelancer_link[:href].match('/users/')
      end

      @@counter += 1
      request_to :parse, url: "https://www.upwork.com/o/profiles/browse/?page=#{@@counter}"
    end

    save_to 'scraped_links.json', freelancers_links, format: :pretty_json
  end

  def solve_recaptcha(recaptcha_key, current_url)
    options = {
      googlekey: "#{recaptcha_key}",
      pageurl: "#{current_url}"
    }
    puts options
    captcha = @@client.decode_recaptcha_v2(options)
    puts "Waiting for decoding"
    sleep(rand(15..30))
    while captcha.text.to_s.blank? do
      sleep(rand(5..10))
    end
    captcha.text
  end

end

UpworkSpider.crawl!

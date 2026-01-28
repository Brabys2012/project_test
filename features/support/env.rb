# frozen_string_literal: true

require 'rest-client'
require 'active_support/all'
require_relative 'helpers/rest_wrapper'
require_relative 'helpers/logger'
require_relative 'helpers/step_helper'
require 'capybara/cucumber'
require 'selenium-webdriver'
require_relative 'helpers/class_extentions'

def browser_setup(browser = 'firefox', use_selenoid = false, browser_version = nil)
  if use_selenoid
    # Подключение к Selenoid (Selenium 4 API)
    selenoid_url = ENV['SELENOID_URL'] || 'http://localhost:4444'
    selenoid_hub = "#{selenoid_url}/wd/hub/"

    browser_version ||= ENV['BROWSER_VERSION'] || '128'

    Capybara.register_driver :selenoid_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--window-size=1920,1080')

      # W3C: опции Selenoid передаём в selenoid:options
      selenoid_caps = Selenium::WebDriver::Remote::Capabilities.new
      selenoid_caps['selenoid:options'] = {
        'enableVNC' => true,
        'screenResolution' => '1920x1080x24',
        'version' => browser_version
      }

      client = Selenium::WebDriver::Remote::Http::Default.new
      client.read_timeout = 140 if client.respond_to?(:read_timeout=)

      Capybara::Selenium::Driver.new(
        app,
        browser: :remote,
        url: selenoid_hub,
        capabilities: [options, selenoid_caps],
        http_client: client
      )
    end

    Capybara.default_driver = :selenoid_chrome
    Capybara.default_selector = :xpath
    Capybara.default_max_wait_time = 15
  else
    # Локальный драйвер (оригинальный код)
    case browser
    when 'chrome'
      Capybara.register_driver :chrome do |app|
        Selenium::WebDriver::Chrome.driver_path = 'configuration/chromedriver'
        profile = Selenium::WebDriver::Chrome::Profile.new
        profile['profile.default_content_settings.popups'] = 0 # custom location
        profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream, text/xml'
        profile['pdfjs.disabled'] = true
        Capybara::Selenium::Driver.new(app, browser: :chrome,
                                            desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                                              'chromeOptions' => {
                                                'args' => ['--window-size=1920,1080'],
                                                'prefs' => {
                                                  'download.default_directory' => Dir.pwd + '/features/tmp/',
                                                  'download.prompt_for_download' => false,
                                                  'plugins.plugins_disabled' => ['Chrome PDF Viewer']
                                                }
                                              }
                                            ))
      end
      Capybara.default_driver = :chrome
      Capybara.page.driver.browser.manage.window.maximize
      Capybara.default_selector = :xpath
      Capybara.default_max_wait_time = 15
    else
      Capybara.register_driver :firefox_driver do |app|
        profile = Selenium::WebDriver::Firefox::Profile.new
        Selenium::WebDriver::Firefox.driver_path = 'configuration/geckodriver'
        profile['browser.download.folderList'] = 2 # custom location
        profile['browser.download.dir'] = Dir.pwd + '/features/tmp/'
        profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream, text/xml'
        profile['pdfjs.disabled'] = true
        Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile, port: Random.rand(7000..7999))
      end
      Capybara.default_driver = :firefox_driver
    end
  end
end

# По умолчанию Selenoid (чтобы REST-тесты не трогали chromedriver). Локальный браузер: USE_SELENOID=false
$use_selenoid = ENV['USE_SELENOID'] != 'false'
$selenoid_url = (ENV['SELENOID_URL'] || 'http://localhost:4444').sub(%r{/$}, '') # без завершающего слэша
browser_setup('chrome', $use_selenoid)

configuration = YAML.load_file 'configuration/default.yml'
$rest_wrap = RestWrapper.new url: 'https://testing4qa.ediweb.ru/api',
                             **configuration[:credentials]
logger_initialize

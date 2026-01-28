# frozen_string_literal: true

require 'uri'
require 'fileutils'
require 'net/http'

DOWNLOAD_DIR = (Dir.pwd + '/features/tmp/').freeze

When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url
  $logger.info("Страница #{url} открыта")
  sleep 2
end

When(/^открываю главную страницу Ruby "([^"]*)"$/) do |url|
  visit url
  $logger.info("Открыта главная страница Ruby: #{url}")
  sleep 2
end

When(/^перехожу на страницу загрузок "([^"]*)"$/) do |url|
  FileUtils.mkdir_p(DOWNLOAD_DIR) unless Dir.exist?(DOWNLOAD_DIR)
  visit url
  $logger.info("Переход на страницу загрузок: #{url}")
  sleep 2
end

When(/^запоминаю имя файла последнего стабильного релиза на странице$/) do
  # Первая ссылка на стабильный релиз (ruby-X.Y.Z.tar.gz) в секции "Стабильные релизы"
  link = find(:xpath, "//a[contains(@href, '.tar.gz') and not(contains(@href, 'preview') or contains(@href, 'snapshot'))]", match: :first)
  href = link[:href]
  @expected_ruby_filename = File.basename(URI.parse(href).path)
  $logger.info("Ожидаемое имя файла с сайта: #{@expected_ruby_filename}")
end

When(/^скачиваю последний стабильный релиз Ruby$/) do
  link = find(:xpath, "//a[contains(@href, '.tar.gz') and not(contains(@href, 'preview') or contains(@href, 'snapshot'))]", match: :first)
  link.click

  path = File.join(DOWNLOAD_DIR, @expected_ruby_filename)

  if $use_selenoid
    # Через Selenoid: файл скачивается в контейнер, забираем по API (как в kablanim)
    sleep 5 # даём время на скачивание в контейнере
    file_url = "#{$selenoid_url}/download/#{page.driver.browser.session_id}/#{@expected_ruby_filename}"
    $logger.info("Selenoid: загрузка файла по URL: #{file_url}")

    retry_count = 10
    response = nil
    retry_count.times do |i|
      $logger.info("Попытка №#{i + 1} скачать файл из Selenoid")
      begin
        uri = URI.parse(file_url)
      rescue URI::InvalidURIError
        uri = URI.parse(URI::DEFAULT_PARSER.escape(file_url))
      end
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 60
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      break if response.code == '200'
      sleep 1
    end

    case response&.code
    when '200'
      FileUtils.mkdir_p(DOWNLOAD_DIR) unless Dir.exist?(DOWNLOAD_DIR)
      File.open(path, 'wb') { |f| f.write(response.body) }
      $logger.info("Файл из Selenoid сохранён: #{path}")
    when '404'
      raise "Файл не найден в Selenoid: #{@expected_ruby_filename}"
    else
      raise "Ошибка загрузки из Selenoid: #{response&.code} #{response&.message}"
    end
  else
    # Локальный браузер: ждём появления файла в директории загрузок (макс. 60 сек)
    timeout = 60
    step_start = Time.now
    until File.exist?(path)
      break if (Time.now - step_start) > timeout
      sleep 1
    end
    sleep 2 if File.exist?(path)
    raise "Файл #{@expected_ruby_filename} не появился в #{DOWNLOAD_DIR} за #{timeout} сек" unless File.exist?(path)
  end

  raise "Файл #{@expected_ruby_filename} не найден после скачивания" unless File.exist?(path)
  $logger.info("Скачивание завершено: #{@expected_ruby_filename}")
end

Then(/^скачанный файл должен находиться в директории загрузок$/) do
  path = File.join(DOWNLOAD_DIR, @expected_ruby_filename)
  expect(File.exist?(path)).to be true
  expect(File.file?(path)).to be true
  $logger.info("Файл найден в директории загрузок: #{path}")
end

Then(/^имя скачанного файла совпадает с именем файла на сайте$/) do
  path = File.join(DOWNLOAD_DIR, @expected_ruby_filename)
  actual_filename = File.basename(path)
  expect(actual_filename).to eq(@expected_ruby_filename)
  $logger.info("Имя скачанного файла совпадает с именем на сайте: #{actual_filename}")
end

When(/^ввожу в поисковой строке текст "([^"]*)"$/) do |text|
  query = find("//input[@name='q']")
  query.set(text)
  query.native.send_keys(:enter)
  $logger.info('Поисковый запрос отправлен')
  sleep 1
end

When(/^кликаю по строке выдачи с адресом (.+?)$/) do |url|
  link_first = find("//a[@href='#{url}/']/h3")
  link_first.click
  $logger.info("Переход на страницу #{url} осуществлен")
  sleep 1
end

When(/^я должен увидеть текст на странице "([^"]*)"$/) do |text_page|
  sleep 1
  expect(page).to have_text text_page
end

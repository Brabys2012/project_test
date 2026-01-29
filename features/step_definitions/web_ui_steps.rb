# frozen_string_literal: true

When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url
  $logger.info("Страница #{url} открыта")
  sleep 2
end

When(/^перехожу на страницу загрузок$/) do
  @page_object.ensure_directory(path: Constants::DOWNLOAD_DIR)
  expect(ruby_main_page).to have_installation_link(wait: 2)
  ruby_main_page.installation_link.click
  expect(installation_page).to have_downloads_links(wait: 2)
  installation_page.downloads_links.first.click
  expect(downloads_page).to be_displayed
  $logger.info("Открыта страница загрузок: #{downloads_page.current_url}")
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

# frozen_string_literal: true

def downloads_page
  @page_object.create_instance(DownloadsPage)
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

When(/^запоминаю имя файла последнего стабильного релиза на странице$/) do
  # Первая ссылка на стабильный релиз (ruby-X.Y.Z.tar.gz) в секции "Стабильные релизы"
  href = downloads_page.stable_release_links.first[:href]
  @expected_ruby_filename = File.basename(URI.parse(href).path)
  $logger.info("Ожидаемое имя файла с сайта: #{@expected_ruby_filename}")
end

When(/^скачиваю последний стабильный релиз Ruby$/) do
  downloads_page.stable_release_links.first.click

  @page_object.wait_and_save_download(
    download_dir: Constants::DOWNLOAD_DIR,
    filename: @expected_ruby_filename
  )
end

Then(/^скачанный файл должен находиться в директории загрузок$/) do
  path = @page_object.path_for_download(@expected_ruby_filename) # или FilesOperations.path_for_download(...)
  expect(File.exist?(path)).to be true
  expect(File.file?(path)).to be true
  $logger.info("Файл найден в директории загрузок: #{path}")
end

Then(/^имя скачанного файла совпадает с именем файла на сайте$/) do
  path = @page_object.path_for_download(@expected_ruby_filename) # или FilesOperations.path_for_download(...)
  actual_filename = File.basename(path)
  expect(actual_filename).to eq(@expected_ruby_filename)
  $logger.info("Имя скачанного файла совпадает с именем на сайте: #{actual_filename}")
end

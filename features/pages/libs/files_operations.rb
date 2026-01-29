# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'fileutils'

module FilesOperations
  # Создаёт директорию, если её ещё нет.
  def ensure_directory(path:)
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
  end

  def path_for_download(filename)
    File.join(Constants.download_dir, filename)
  end

  # Скачивает файл после клика по ссылке: через Selenoid API или ожидание в локальной директории.
  # Возвращает путь к сохранённому файлу.
  def wait_and_save_download(download_dir:, filename:, retry_count: 120)
    path = File.join(download_dir, filename)

    if $use_selenoid
      file_url = "#{$selenoid_url}/download/#{page.driver.browser.session_id}/#{filename}"
      $logger.info("Selenoid: загрузка файла по URL: #{file_url}")

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
        FileUtils.mkdir_p(download_dir) unless Dir.exist?(download_dir)
        File.open(path, 'wb') { |f| f.write(response.body) }
        $logger.info("Файл из Selenoid сохранён: #{path}")
      when '404'
        raise "Файл не найден в Selenoid: #{filename}"
      else
        raise "Ошибка загрузки из Selenoid: #{response&.code} #{response&.message}"
      end
    else
      timeout = 60
      step_start = Time.now
      until File.exist?(path)
        break if (Time.now - step_start) > timeout

        sleep 1
      end
      sleep 2 if File.exist?(path)
      raise "Файл #{filename} не появился в #{download_dir} за #{timeout} сек" unless File.exist?(path)
    end

    raise "Файл #{filename} не найден после скачивания" unless File.exist?(path)

    $logger.info("Скачивание завершено: #{filename}")
    path
  end
end

# frozen_string_literal: true

require_relative 'installation_page'

class DownloadsPage < InstallationPage
  set_url "#{MainPage.base_url}downloads/"

  # Ссылка на страницу загрузок
  elements :downloads_links, :xpath, "//a[contains(@href, '/downloads/')]"
  elements :stable_release_links, :xpath,
           "//a[contains(@href, '.tar.gz') and not(contains(@href, 'preview') or contains(@href, 'snapshot'))]"
end

# frozen_string_literal: true

require_relative 'main_page'

class InstallationPage < MainPage
  # Ссылки на страницу загрузок
  elements :downloads_links, :xpath, "//a[contains(@href, '/downloads/')]"
end

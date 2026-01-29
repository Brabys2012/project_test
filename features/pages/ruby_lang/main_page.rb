# frozen_string_literal: true

# Главная страница https://www.ruby-lang.org/ru/
class MainPage < SitePrism::Page
  def self.base_url
    @base_url ||= 'https://www.ruby-lang.org/ru/'
  end

  set_url base_url

  # Ссылка «Скачать» в навигации (href="/ru/documentation/installation/")
  element :installation_link, :xpath, "//a[contains(@href, '/ru/documentation/installation/')]"
end

# frozen_string_literal: true

# Главная страница https://www.ruby-lang.org/ru/
class MainPage < SitePrism::Page
  BASE_URL = 'https://www.ruby-lang.org/ru/'

  set_url BASE_URL

  # Ссылка «Скачать» в навигации (href="/ru/documentation/installation/")
  element :installation_link, :xpath, "//a[contains(@href, '/ru/documentation/installation/')]"
end
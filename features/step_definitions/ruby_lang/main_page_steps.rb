# frozen_string_literal: true

def ruby_main_page
  @page_object.create_instance(MainPage)
end

When(/^открываю главную страницу Ruby$/) do
  ruby_main_page.load
  expect(ruby_main_page).to be_displayed
  $logger.info("Открыта главная страница Ruby: #{ruby_main_page.current_url}")
end

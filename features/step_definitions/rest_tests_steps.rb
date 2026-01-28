# frozen_string_literal: true

When(/^получаю информацию о пользователях$/) do
  users_full_information = $rest_wrap.get('/users')

  $logger.info('Информация о пользователях получена')
  @scenario_data.users_full_info = users_full_information
end

When(/^проверяю (наличие|отсутствие) логина ([\w.]+) в списке пользователей$/) do |presence, login|
  search_login_in_list = true
  presence == 'отсутствие' ? search_login_in_list = !search_login_in_list : search_login_in_list

  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
  login_presents = logins_from_site.include?(login)

  if login_presents
    message = "Логин #{login} присутствует в списке пользователей"
    search_login_in_list ? $logger.info(message) : raise(message)
  else
    message = "Логин #{login} отсутствует в списке пользователей"
    search_login_in_list ? raise(message) : $logger.info(message)
  end
end

When(/^добавляю пользователя c логином ([\w.]+) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+)$/) do
|login, name, surname, password|

  response = $rest_wrap.post('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: 1)
  $logger.info(response.inspect)
end

When(/^добавляю пользователя с параметрами:$/) do |data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]

  step "добавляю пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password}"
end

When(/^нахожу пользователя с логином ([\w.]+)$/) do |login|
  ensure_user_id_loaded(login)
  $logger.info("Найден пользователь #{login} с id:#{@scenario_data.users_id[login]}")
end

When(/^удаляю пользователя с логином ([\w.]+)$/) do |login|
  ensure_user_id_loaded(login)
  user_id = @scenario_data.users_id[login]
  $rest_wrap.delete("/users/#{user_id}")
  $logger.info("Пользователь с логином #{login} (id: #{user_id}) удалён")
  @scenario_data.users_id.delete(login)
end

When(/^удаляю пользователя с логином ([\w.]+) если он существует$/) do |login|
  step 'получаю информацию о пользователях' if @scenario_data.users_full_info.nil?
  return unless @scenario_data.users_full_info.map { |u| u['login'] }.include?(login)
  ensure_user_id_loaded(login)
  user_id = @scenario_data.users_id[login]
  $rest_wrap.delete("/users/#{user_id}")
  $logger.info("Пользователь с логином #{login} (id: #{user_id}) удалён (очистка)")
  @scenario_data.users_id.delete(login)
  @scenario_data.users_full_info = $rest_wrap.get('/users')
end

When(/^изменяю параметры пользователя с логином ([\w.]+)$/) do |login, table|
  ensure_user_id_loaded(login)
  user_id = @scenario_data.users_id[login]
  params = table.rows_hash.transform_keys(&:to_sym)
  $rest_wrap.put("/users/#{user_id}", params)
  $logger.info("Параметры пользователя #{login} (id: #{user_id}) обновлены: #{params.inspect}")
  step 'получаю информацию о пользователях'
end

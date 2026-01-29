# frozen_string_literal: true

When(/^получаю информацию о пользователях$/) do
  users_full_information = $rest_wrap.get('/users')

  $logger.info('Информация о пользователях получена')
  @scenario_data.users_full_info = users_full_information
end

When(/^проверяю (наличие|отсутствие) логина ([\w.]+) в списке пользователей$/) do |presence, login|
  search_login_in_list = (presence != 'отсутствие')

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

When(/^добавляю пользователя c логином ([\w.]+) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+)$/) do |login, name, surname, password|
  response = $rest_wrap.post('/users',
                             login: login,
                             name: name,
                             surname: surname,
                             password: password,
                             active: 1)
  $logger.info(response.inspect)
end

When(/^снова добавляю пользователя c логином ([\w.]+) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+) и ожидаю ошибку$/) do |login, name, surname, password|
  expect do
    $rest_wrap.post('/users', login: login, name: name, surname: surname, password: password, active: 1)
  end.to raise_error(StandardError,
                     /Ошибка \d+|409|422|400|Bad Request|конфликт|duplicate|уже существует|unexpected token/i)
  $logger.info('Ожидаемая ошибка при дубликате логина получена')
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
  if @scenario_data.users_full_info.map { |u| u['login'] }.include?(login)
    ensure_user_id_loaded(login)
    user_id = @scenario_data.users_id[login]
    $rest_wrap.delete("/users/#{user_id}")
    $logger.info("Пользователь с логином #{login} (id: #{user_id}) удалён (очистка)")
    @scenario_data.users_id.delete(login)
    @scenario_data.users_full_info = $rest_wrap.get('/users')
  end
end

When(/^пытаюсь удалить пользователя с логином ([\w.]+) и ожидаю ошибку$/) do |login|
  step 'получаю информацию о пользователях'

  expect do
    ensure_user_id_loaded(login)
    user_id = @scenario_data.users_id[login]
    $rest_wrap.delete("/users/#{user_id}")
  end.to raise_error(StandardError, /Ошибка \d+|404|0|неуникален|не найден|не найден в списке/i)
  $logger.info('Ожидаемая ошибка при удалении отсутствующего пользователя получена')
end

When(/^проверяю что пользователь с логином ([\w.]+) в списке имеет имя (\w+) фамилию (\w+)$/) do |login, name, surname|
  step 'получаю информацию о пользователях' if @scenario_data.users_full_info.nil?
  user = @scenario_data.users_full_info.find { |u| u['login'] == login }
  expect(user).not_to be_nil, "Пользователь с логином #{login} не найден в списке"
  expect(user['name']).to eq(name), "Ожидалось имя #{name}, получено: #{user['name']}"
  expect(user['surname']).to eq(surname), "Ожидалась фамилия #{surname}, получено: #{user['surname']}"
  $logger.info("Пользователь #{login}: имя=#{user['name']}, фамилия=#{user['surname']}")
end

When(/^изменяю параметры пользователя с логином ([\w.]+)$/) do |login, table|
  ensure_user_id_loaded(login)
  user_id = @scenario_data.users_id[login]
  params = table.rows_hash.transform_keys(&:to_sym)
  $rest_wrap.put("/users/#{user_id}", params)
  $logger.info("Параметры пользователя #{login} (id: #{user_id}) обновлены: #{params.inspect}")
  step 'получаю информацию о пользователях'
end

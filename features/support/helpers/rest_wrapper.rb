# frozen_string_literal: true

class RestWrapper
  attr_accessor :url, :login, :password

  def initialize(url:, login:, password:)
    @url = url
    @login = login
    @password = password
  end

  def get(current_url, _params = {})
    response = RestClient::Request.execute(
      method: :get,
      url: compile_full_url(current_url),
      user: login,
      password: password,
      accept: 'application/json',
      headers: { content_type: 'application/json' }
    )
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  def post(current_url, params = {})
    response = RestClient::Request.execute(
      method: :post,
      url: compile_full_url(current_url),
      user: login,
      password: password,
      payload: params.to_json,
      headers: { content_type: 'application/json' }
    )
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  def put(current_url, params = {})
    response = RestClient::Request.execute(
      method: :put,
      url: compile_full_url(current_url),
      user: login,
      password: password,
      payload: params.to_json,
      headers: { content_type: 'application/json' }
    )
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  def delete(current_url, params = {})
    response = RestClient::Request.execute(
      method: :delete,
      url: compile_full_url(current_url),
      user: login,
      password: password,
      payload: params.to_json,
      headers: { content_type: 'application/json' }
    )
    JSON.parse(response)
  rescue StandardError => e
    send_error e
  end

  private

  def send_error(exception)
    puts exception.inspect
    unless exception.respond_to?(:response) && exception.response
      raise "Ошибка сети или соединения: #{exception.class} — #{exception.message}"
    end

    body = exception.response.body
    raise_message = if body.is_a?(String)
                      "Ошибка #{exception.response.code} с текстом #{JSON.parse(body)}"
                    else
                      "Ошибка #{exception}"
                    end
    raise raise_message
  rescue JSON::ParserError
    raise "Ошибка #{exception.response.code} с телом ответа (не JSON): #{body.to_s[0..200]}"
  end

  def compile_full_url(current_url)
    url + current_url
  end
end

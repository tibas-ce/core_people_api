module RequestHelper
  def json
    JSON.parse(response.body)
  end

  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id)
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def get_auth(path, user:, params: {})
    get path, params: params, headers: auth_headers(user)
  end

  def post_auth(path, user:, params: {})
    post path, params: params.to_json, headers: auth_headers(user)
  end

  def put_auth(path, user:, params: {})
    put path, params: params.to_json, headers: auth_headers(user)
  end

  def delete_auth(path, user:, params: {})
    delete path, headers: auth_headers(user)
  end
end

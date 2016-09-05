module AuthHelpers
  def auth_request(user)
    request.headers.merge!(user.create_new_auth_token)
  end
end

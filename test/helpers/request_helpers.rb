module Requests
  module JsonHelpers
    # GET and POST shortcuts for JSON
    def get_json(path)
      get path, format: :json
      json_parse(response.body)
    end

    def post_json(url, data)
      post(url, data, format: :json)
      json_parse(response.body)
    end

    # JSON parsing
    def json_response
      json_parse(response.body)
    end

    def json_parse(body)
      JSON.parse(body)
    end
  end

  module HeadersHelpers
    def api_header(format = Mime::JSON)
      request.headers['Accept'] = format
      request.headers['Content-Type'] = format
    end

    def api_auth_header(user)
      request.headers.merge!(user.create_new_auth_token)
    end

    def api_non_auth_header
      request.headers.merge!(non_auth_header)
    end

    def non_auth_header
      {
          'access-token' => 'invalid-access-token',
          'token-type' => 'Bearer',
          'client' => 'invalid-client',
          'expiry' => '1000000000',
          'uid' => 'invalid-user'
      }
    end
  end
end

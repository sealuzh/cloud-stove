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
      MultiJson.load(body, symbolize_keys: false)
    end
  end
end

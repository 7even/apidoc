module Formatter
  class << self
    def format_query(query_params)
      Faraday::Utils.build_nested_query(query_params)
    end
    
    def format_body(body_params)
      json = JSON.pretty_generate(body_params)
      json.gsub(/\"#\{([A-Za-z0-9_]+)\}\"/, '\1')
    end
  end
end

class IncomingRequest
  def initialize(rack_request)
    @rack_request = rack_request
  end
  
  def verb_matches?(verb)
    @rack_request.request_method == verb
  end
  
  def url_matches?(url)
    !!url_params(url)
  end
  
  def url_params(url)
    pattern = IncomingRequest.pattern_from_url(url)
    match = Regexp.new(pattern).match(@rack_request.path_info)
    Hash[match.names.zip(match.captures)] if match
  end
  
  def query_string_matches?(query_params)
    query_params.keys.all? do |param_name|
      @rack_request.GET.has_key?(param_name.to_s)
    end
  end
  
  def headers_match?(headers)
    headers.keys.all? do |header_name|
      cgi_name = "HTTP_#{header_name.upcase.gsub(/-/, '_')}"
      @rack_request.env.has_key?(cgi_name)
    end
  end
  
  def body_matches?(body_params)
    body_params.keys.all? do |param_name|
      form_hash.has_key?(param_name.to_s)
    end
  end
  
  def self.pattern_from_url(url)
    url.gsub(/:([a-z0-9_]+)/, '(?<\1>[A-Za-z0-9_]+)')
  end
  
private
  def form_hash
    @form_hash ||= if @rack_request.form_data?
      Rack::Utils.parse_nested_query(@rack_request.body.read)
    else
      Oj.load(@rack_request.body.read)
    end
  end
end

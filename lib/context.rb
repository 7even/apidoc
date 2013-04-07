class Context
  include Mongoid::Document
  
  field :request_query_params, type: Hash
  field :request_headers,      type: Hash
  field :request_body_params,  type: Hash
  field :response_code,        type: Integer
  field :response_headers,     type: Hash
  field :response_body_params, type: Hash
  
  embedded_in :request
  
  %i(request_query_params request_headers request_body_params response_code response_headers response_body_params).each do |attr_name|
    define_method "has_#{attr_name}?" do
      !self[attr_name].nil?
    end
  end
  
  def has_request_params?
    self.has_request_query_params? || self.has_request_headers? || self.has_request_body_params?
  end
  
  def has_response_params?
    self.has_response_code? || self.has_response_headers? || self.has_response_body_params?
  end
  
  def matches?(request)
    query_string_matches?(request) && headers_match?(request) && body_matches?(request)
  end
  
  def apply(response)
    response.status = self.response_code if self.has_response_code?
    
    self.response_headers.each do |header_name, header_value|
      response.headers[header_name] = header_value
    end if self.has_response_headers?
    
    response.body << Oj.dump(self.response_body_params) if self.has_response_body_params?
  end
  
private
  def query_string_matches?(request)
    self.request_query_params.nil? || request.query_string_matches?(self.request_query_params)
  end
  
  def headers_match?(request)
    self.request_headers.nil? || request.headers_match?(self.request_headers)
  end
  
  def body_matches?(request)
    self.request_body_params.nil? || request.body_matches?(self.request_body_params)
  end
end

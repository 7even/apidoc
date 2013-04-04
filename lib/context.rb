class Context
  include Mongoid::Document
  
  field :request_query_string, type: Hash
  field :request_headers,      type: Hash
  field :request_body,         type: Hash
  field :response_code,        type: Integer
  field :response_headers,     type: Hash
  field :response_body,        type: Hash
  
  embedded_in :request
  
  %i(request_query_string request_headers request_body response_code response_headers response_body).each do |attr_name|
    define_method "has_#{attr_name}?" do
      !self[attr_name].nil?
    end
  end
  
  def has_request_params?
    self.has_request_query_string? || self.has_request_headers? || self.has_request_body?
  end
  
  def has_response_params?
    self.has_response_code? || self.has_response_headers? || self.has_response_body?
  end
end

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
end

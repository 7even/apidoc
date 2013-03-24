class Context
  include Mongoid::Document
  
  field :request_query_string, type: String
  field :request_headers,      type: Hash
  field :request_body,         type: String
  field :response_code,        type: Integer
  field :response_headers,     type: Hash
  field :response_body,        type: String
  
  embedded_in :request
end

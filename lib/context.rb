class Context
  include Mongoid::Document
  
  field :request_headers
  field :request_query_string
  field :request_body
  field :response_code
  field :response_headers
  field :response_body
  
  embedded_in :request
end

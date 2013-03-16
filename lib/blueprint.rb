class Blueprint
  include Mongoid::Document
  
  embeds_many :requests
end

# blueprint:
#   request:
#     verb
#     url
#     context:
#       request_headers
#       request_query_string
#       request_body
#       response_code
#       response_headers
#       response_body

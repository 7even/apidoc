class Blueprint
  include Mongoid::Document
  
  embeds_many :requests
  
  def self.parse(specification)
    blueprint = Parser.new.parse(specification)
    blueprint.tap(&:save)
  end
end

# blueprint:
#   request:
#     verb
#     url
#     context:
#       request_query_string
#       request_headers
#       request_body
#       response_code
#       response_headers
#       response_body

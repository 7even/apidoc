class Blueprint
  include Mongoid::Document
  
  field :specification, type: String
  
  embeds_many :requests
  
  def self.parse(specification)
    blueprint = Parser.new.parse(specification)
    blueprint.specification = specification
    blueprint.tap(&:save)
  end
end

# blueprint:
#   specification
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

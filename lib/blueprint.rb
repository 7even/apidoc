class Blueprint
  include Mongoid::Document
  
  field :specification, type: String
  
  embeds_many :requests
  
  class << self
    def parse(specification)
      blueprint = Parser.new.parse(specification)
      blueprint.specification = specification
      blueprint.tap(&:save)
    end
    
    # актуальная спецификация
    def current
      self.last
    end
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

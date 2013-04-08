class Blueprint
  include Mongoid::Document
  
  field :specification, type: String
  
  embeds_many :requests
  
  def process(request, response)
    incoming_request = IncomingRequest.new(request)
    
    request_specification = self.requests.detect do |r|
      r.matches?(incoming_request)
    end
    
    if request_specification
      context_specification = request_specification.contexts.detect do |context|
        context.matches?(incoming_request)
      end
    end
    
    if context_specification
      context_specification.apply(response)
      true # always return a truthy value after successfully finding a matching context
    end
  end
  
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
#       request_query_params
#       request_headers
#       request_body_params
#       response_code
#       response_headers
#       response_body_params

class Request
  include Mongoid::Document
  
  field :verb, type: String
  field :url,  type: String
  
  embedded_in :blueprint
  embeds_many :contexts
  
  def caption
    "#{verb} #{url}" # GET /users
  end
  
  def matches?(incoming_request)
    incoming_request.verb_matches?(self.verb) && incoming_request.url_matches?(self.url)
  end
end

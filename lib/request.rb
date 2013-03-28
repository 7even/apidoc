class Request
  include Mongoid::Document
  
  field :verb, type: String
  field :url,  type: String
  
  embedded_in :blueprint
  embeds_many :contexts
  
  def caption
    "#{verb} #{url}" # GET /users
  end
end

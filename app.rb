require_relative 'init'

subdomain :api do
  get '/' do
    'API'
  end
end

get '/' do
  # TODO: distinguish the real current blueprint from the old
  @current_blueprint = Blueprint.last
  slim :show
end

get '/edit' do
  @current_blueprint = Blueprint.last
  slim :edit
end

post '/' do
  Blueprint.parse(params[:specification])
  redirect '/'
end

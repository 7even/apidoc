require_relative 'init'

subdomain :api do
  [:get, :post, :put, :patch, :delete].each do |verb|
    send(verb, '*') do
      if @current_blueprint = Blueprint.current
        @current_blueprint.process(request, response) or halt 404, 'Request doesn\'t match the specification'
      else
        halt 404, 'Specification missing'
      end
    end
  end
end

get '/' do
  # TODO: distinguish the real current blueprint from the old
  @current_blueprint = Blueprint.current
  slim :show
end

get '/edit' do
  @current_blueprint = Blueprint.current
  slim :edit
end

post '/' do
  Blueprint.parse(params[:specification])
  redirect '/'
end

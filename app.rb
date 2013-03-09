require_relative 'init'

subdomain :api do
  get '/' do
    'API'
  end
end

get '/' do
  'Docs'
end

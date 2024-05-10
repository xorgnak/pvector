
class App < Sinatra::Base
configure do
  set :port, 4567
  set :bind, '0.0.0.0'
  set :views, 'views/'
end
get('/') do
  erb :index
end
post('/') do
  content_type 'application/json'
  JSON.generate({ i: params[:i], o: MIND[params[:i]].join("\n\n") })
end
end

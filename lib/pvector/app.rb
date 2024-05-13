
class App < Sinatra::Base
configure do
  set :port, 4567
  set :bind, '0.0.0.0'
  set :views, 'views/'
end
get('/') do
  erb :index
end
before do
  puts %[---> #{request.path} #{params}]
end
post('/define') do
  content_type 'application/json'
  JSON.generate({ o: MIND.define([ params[:i] ].flatten.join(" ")) })
end
post('/think') do
  content_type 'application/json'
  JSON.generate({ o: MIND.think([ params[:v], params[:i] ].flatten.join(" ")) })
end
post('/lookup') do
  content_type 'application/json'
  JSON.generate({ o: MIND.lookup(params[:i]) })
end
post('/summary') do
  content_type 'application/json'
  JSON.generate({ o: MIND.summary(params[:i]) })
end
post('/respond') do
  content_type 'application/json'
  JSON.generate({ o: MIND.respond([ params[:v], params[:l],  params[:i] ].flatten.join(" ")) })
end
end

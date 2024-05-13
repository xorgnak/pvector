
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
  if %[#{params[:llama]}].length == 0 && %[#{params[:vector]}].length == 0
    puts %[input]
  elsif %[#{params[:vector]}].length == 0
    puts %[lamma + input]
  elsif %[#{params[:llama]}].length == 0
    puts %[vector + input]
  else
    puts %[llama + vector + input]
  end
  o = MIND.respond(params)
  puts "POST #{params} #{o}"
  JSON.generate({ o: o })
end
end

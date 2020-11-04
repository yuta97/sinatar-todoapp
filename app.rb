require 'sinatra'
require 'mysql2'

configure do
  set :bind, '0.0.0.0'
end

# get '/' do
#   'Hello Sinatra!'
# end
get '/initialize' do
  client = Mysql2::Client.new(
    :host => ENV['MYSQL_HOST'],
    :username => ENV['MYSQL_USER'],
    :password => ENV['MYSQL_PASS']
  )
  client.query("DROP DATABASE IF EXISTS #{ENV['MYSQL_DATABASE']}")
  client.query("CREATE DATABASE IF NOT EXISTS #{ENV['MYSQL_DATABASE']} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci")
  client = db_client
  client.query(<<-EOS
      CREATE TABLE IF NOT EXISTS chats (
        id   INT AUTO_INCREMENT,
        name TEXT,
        content TEXT,
        time DATETIME,
        PRIMARY KEY(id)
    )
    EOS
  )
  redirect '/'
end

get '/' do
  chats = chats_fetch
  erb :index, locals: {
        chats: chats.map{ |chat| add_suffix(chat) }
    }
end
  
post '/' do
  chat_push(params['content'])
  redirect back
end

def chat_push(content, name="名無し")
  db_client.prepare(
    "INSERT into chats (name, content, time) VALUES (?, ?, NOW())"
  ).execute(name, content)
end

def chats_fetch()
  db_client.query("SELECT * FROM chats ORDER BY time DESC")
end
def db_client()
  Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
  Mysql2::Client.new(
    :host => ENV['MYSQL_HOST'],
    :username => ENV['MYSQL_USER'],
    :password => ENV['MYSQL_PASS'],
    :database => ENV['MYSQL_DATABASE']
  )
end
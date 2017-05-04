require 'socket'
require 'pry'

puts 'listening...'
Socket.tcp_server_loop(4481) do |conn|
  loop do
    request = conn.gets
    puts request
    break if request.strip == 'exit'
    conn.puts 'hi'
    IO.select(nil, [conn], nil)
  end
end

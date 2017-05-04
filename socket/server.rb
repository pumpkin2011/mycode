require 'socket'
require 'pry'

puts 'listening...'
Socket.tcp_server_loop(4481) do |conn|
  address = conn.remote_address
  puts "#{address.ip_address}:#{address.ip_port} connected!"
  fork do
    loop do
      puts 'waiting'
      IO.select(nil, [conn], nil)
      request = conn.gets
      puts "#{address.ip_address}(#{address.ip_port}): " + request
      exit if (request || '').strip == 'exit' || request.nil?
      conn.puts 'hi'
    end
  end
end

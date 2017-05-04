require 'socket'
require 'pry'

Socket.tcp('127.0.0.1', 4481) do |conn|
  loop do
    puts 'Please input sth:'
    sth = gets.chomp
    conn.puts(sth)
    IO.select([conn])
    puts conn.gets
  end
end

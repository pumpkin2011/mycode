require 'socket'
require 'pry'

Socket.tcp('127.0.0.1', 4481) do |conn|
  loop do
    Thread.new do
      IO.select([conn])
      puts conn.gets
    end

    puts 'Please input sth:'
    sth = gets.chomp
    conn.puts(sth)
  end
end

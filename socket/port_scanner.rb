require 'pry'
require 'socket'

PORT_RANGE = 1..128
HOST = 'baidu.com'
TIME_TO_WAIT = 5

sockets = PORT_RANGE.map do |port|
  socket = Socket.new(:INET, :STREAM)
  remote_addr = Socket.pack_sockaddr_in(port, HOST)

  begin
    socket.connect_nonblock(remote_addr)
  rescue Errno::EINPROGRESS
  end

  socket
end

loop do
  _, writable, _ = IO.select(nil, sockets, nil)

  writable.each do |socket|
    begin
      socket.connect_nonblock(socket.remote_address)
    rescue Errno::EISCONN
      puts "#{HOST}:#{socket.remote_address.ip_port} accepts connections..."
    rescue Errno::EINVAL
#      puts "#{socket.remote_address.ip_port} closed!"
    end
    sockets.delete(socket)
  end
end

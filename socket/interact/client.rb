require 'socket'

CRLF = "\r\n"

socket = TCPSocket.new('localhost', 4481)
loop do
  content = gets
  socket.write_nonblock(content)
end


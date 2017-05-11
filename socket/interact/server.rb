require 'socket'
require 'pry'

CHUNKSIZE = 1024 * 16
CRLF = "\r\n"
@handles = {}
socket = TCPServer.new(4481)

loop do
  conns = @handles.values
  reads, writes = IO.select(conns + [socket], conns)
  reads.each do |read|
    if read == socket 
      conn = read.accept
      add = conn.remote_address
      puts "#{add.ip_address}:#{add.ip_port} connected."
      @handles[conn.fileno] = conn
    else
      begin
        content = read.read_nonblock(CHUNKSIZE)
        puts content
      rescue Errno::EAGAIN
      rescue EOFError
        @handles.delete(read.fileno)
      end
    end

  end
end



# 事件驱动
require 'socket'
require 'pry'

class Connection
  CHUNKSIZE = 1024 * 16
  attr_reader :client

  def initialize(conn)
    @client = conn
  end

  def respond(str)
    @client.write_nonblock(str)
  end

  def data
    @client.read_nonblock(CHUNKSIZE)
  end

  def addrinfo
    addr = @client.remote_address
    "#{addr.ip_address}:#{addr.ip_port}"
  end

end


CRLF = "\r\n"
@handles = {}
socket = TCPServer.new(4481)

loop do
  conns = @handles.values.map(&:client)
  reads, writes = IO.select(conns + [socket], conns)
  reads.each do |read|
    if read == socket 
      conn = Connection.new(read.accept)
      puts conn.addrinfo + 'connected'
      @handles[conn.client.fileno] = conn
    else
      begin
        content = @handles[read.fileno].data
        puts content
      rescue Errno::EAGAIN
      rescue EOFError
        @handles.delete(read.fileno)
      end
    end

  end
end


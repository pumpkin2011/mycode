require 'socket'
require 'thread'
require_relative '../command_handler'

module FTP
  Connection = Struct.new(:client) do
    CRLF = "\r\n"
    def gets
      client.gets(CRLF)
    end

    def respond(message)
      client.write(message)
      client.write(CRLF)
    end

    def close
      client.close
    end
  end

  class ThreadPool
    CONCURRENCY = 25
    def initialize(port = 21)
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    def run
      Thread.abort_on_exception = true
      # ThreadGroup可以跟踪所有的线程
      # 当某个线程成员执行结束后，它就会从这个组中丢弃
      threads = ThreadGroup.new
      CONCURRENCY.times do
        threads.add spawn_thread
      end
      # 避免退出
      # 理论上它可以监视线程池
      sleep
    end

    def spawn_thread
      Thread.new do
        loop do
          conn = Connection.new(@control_socket.accept)
          conn.respond "220 OHAI"
          handler = CommandHandler.new(self)
          loop do
            request = conn.gets
            if request
              conn.respond handler.handle(request)
            else
              conn.close
              break
            end
          end
        end
      end
    end
  end
end

server = FTP::ThreadPool.new(4481)
server.run

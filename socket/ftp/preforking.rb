require 'socket'
require 'pry'
require_relative './command_handler'

module FTP
  class Preforking
    CRLF = "\r\n"
    CONCURRENCY = 4

    def initialize(port = 21)
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    def gets
      @client.gets(CRLF)
    end

    def respond(message)
      @client.write(message)
      @client.write(CRLF)
    end

    def run
      child_pids = []

      CONCURRENCY.times do
        child_pids << spawn_child
      end

      trap(:INT) {
        child_pids.each do |cpid|
          begin
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end
        exit
      }

      loop do
        # wait会一直保持堵塞，直到一个子进程退出为止
        pid = Process.wait
        $stderr.puts "Process #{pid} quit unexpectedly"
        child_pids.delete(pid)
        child_pids << spawn_child
      end
    end

    def spawn_child
      fork do
        loop do
          @client = @control_socket.accept
          respond "220 OHAI"
          handler = CommandHandler.new(self)

          loop do
            request = gets
            if request
              respond handler.handle(request)
            else
              @client.close
              break
            end
          end

        end
      end
    end
  end
end

server = FTP::Preforking.new(4481)
server.run

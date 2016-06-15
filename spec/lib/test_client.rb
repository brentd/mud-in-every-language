require "socket"

class TestClient
  attr_reader :port, :log

  def initialize(port:)
    @port = port
  end

  def connect
    @socket = TCPSocket.open("0.0.0.0", port)
    @out = Queue.new
    @log = []

    Thread.new do
      while line = @socket.gets("\n")
        line = line.rstrip
        @log << line
        @out << line
      end
    end
  end

  def disconnect
    @socket.close
  end

  def input(str)
    @log << "> #{str}"
    @socket.puts(str)
  end

  def readlines_until(timeout = 1)
    time = Time.now
    matched = false
    Thread.new do
      until matched = yield(@out.pop); end
    end
    until matched || Time.now - time >= timeout; end
    matched
  end
end

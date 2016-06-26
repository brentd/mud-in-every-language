require "socket"

class TestClient
  attr_reader :port, :log, :socket, :out

  def initialize(port:, log: StringIO.new)
    @port      = port
    @log       = log
    @out, @buf = IO.pipe
  end

  def connect
    @socket = TCPSocket.open("0.0.0.0", port)

    # Log all reads from the socket, while buffering the data to
    # `out` so it can be read by other consumers.
    Thread.new do
      sleep 0.01
      begin
        @log.puts "[Client connected]".yellow
        @socket.each_line do |line|
          @buf << line
          @log << "| #{line}"
        end
      rescue Errno::ECONNRESET
        @log.puts "[Client disconnected by server]".yellow
      end
    end
  end

  def disconnect
    @socket.close
    @log.puts "[Client disconnected]".yellow
  end

  def reconnect
    disconnect
    connect
  end

  def closed?
    @socket.eof?
  end
  alias_method :disconnected?, :closed?

  def puts(str)
    @log.puts "> #{str}".green
    @socket.puts(str)
  end

  def <<(str)
    puts str
  end

  def each(*args, &blk)
    @out.each(*args, &blk)
  end
end

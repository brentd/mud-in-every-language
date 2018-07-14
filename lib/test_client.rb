require "socket"
require "timeout"

class TestClient
  attr_reader :port, :log, :socket, :out

  def initialize(port:, log: StringIO.new)
    @port      = port
    @log       = log
    @out, @buf = IO.pipe
  end

  def connect
    return self if connected?

    @socket = TCPSocket.open("0.0.0.0", port)

    Thread.new do
      begin
        @log.puts "[Client connected]".yellow
        @socket.each_line do |line|
          @buf << line
          @log << "#{line}"
        end
      rescue Errno::ECONNRESET
        @log.puts "[Client disconnected by server]".yellow
      end
    end

    return self
  end

  def disconnect
    if connected?
      @socket.close
      @log.puts "[Client disconnected]".yellow
    end
  end

  def reconnect
    disconnect
    connect
  end

  def connected?
    @socket && !@socket.closed?
  end

  def eof?
    Timeout.timeout(0.5) { @socket.eof? }
  rescue Timeout::TimeoutError
    false
  end

  def disconnected?
    !connected? || eof?
  end

  def puts(str)
    @log.puts "> #{str}".green
    @socket.puts(str)
  end

  def <<(str)
    puts str
  end

  def each_line(*args, &blk)
    @out.each(*args, &blk)
  end
end

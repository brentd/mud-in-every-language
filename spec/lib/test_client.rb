require "socket"

class TestClient
  attr_reader :port, :log, :socket, :out

  def initialize(port:, log: StringIO.new)
    @port = port
    @log  = log
    @out  = StringIO.new
  end

  def connect
    @socket = TCPSocket.open("0.0.0.0", port)
    @log.puts "[Client connected]".yellow
  end

  def disconnect
    @socket.close
    @log.puts "[Client disconnected]".yellow
  end

  def reconnect
    disconnect
    connect
  end

  def puts(str)
    @log.puts "> #{str}".yellow
    @socket.puts(str)
  end
  alias_method :<<, :puts

  def each_line(*args)
    @socket.each_line(*args) do |line|
      @out << line
      @log << "#{line}"
      yield line
    end
  rescue Errno::ECONNRESET
    @log.puts "[Client disconnected by server]".yellow
  end
end

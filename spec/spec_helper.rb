require "socket"
require "pty"

class ServerRunner
  # TODO: pass port and environment
  CMD = "ruby ruby/server.rb"

  attr_reader :port

  def initialize(port:)
    @port = port
  end

  def start
    Thread.abort_on_exception = true
    ready = false
    Thread.new do
      PTY.spawn("#{CMD} -p #{port} --test-mode") do |stdout, stdin, pid|
        @pid = pid
        @stdin = stdin
        stdout.each do |line|
          ready = true if line =~ /Server running/
        end
      end
    end
    until ready; end
  end

  def stop
    Process.kill('SIGKILL', @pid)
  end
end

class TestClient
  attr_reader :port, :log

  def initialize(port:)
    @port = port
  end

  def connect
    @socket = TCPSocket.open("0.0.0.0", port)
    @out = StringIO.new
    @log = []

    Thread.new do
      while line = @socket.gets("\n")
        line = line.rstrip
        @log << line
        @out.puts line
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

  def readlines_until(timeout=1)
    time = Time.now
    ready = false
    Thread.new do
      while line = @out.gets
        raise "GOT A KIE OANADAS"
        ready = yield line
        break if ready
      end
    end
    until ready || Time.now - time >= timeout; end
    ready
  end
end

module Assertions
  def assert_displayed(str)
    self.assertions += 1

    # passed = false
    # time = Time.now

    # thread = Thread.new do
    #   while line = @client.gets("\n").rstrip
    #     passed = case str
    #              when Regexp then str =~ line
    #              when String then str == line
    #              end
    #     break if passed
    #   end
    # end

    # until passed || Time.now - time >= 2; end

    passed = @client.readlines_until do |line|
      if str.respond_to?(:=~)
        str =~ line
      else
        str == line
      end
    end

    if !passed
      msg = @client.log.dup
      msg << "#{str.inspect} was not displayed"
      raise Minitest::Assertion, msg.join("\n")
    end
  end
end

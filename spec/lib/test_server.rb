require "pty"

class TestServer
  # TODO: pass this as an arg
  CMD = "ruby ruby/server.rb"

  attr_reader :port

  def initialize(port:)
    @port = port
  end

  def start
    Thread.new do
      Thread.current.abort_on_exception = true
      PTY.spawn("#{CMD} -p #{port} --test-mode") do |stdout, stdin, pid|
        @pid = pid
        stdout.each do |line|
          Thread.main.wakeup if line =~ /Server running/
        end
      end
    end
    sleep
  end

  def stop
    Process.kill('SIGKILL', @pid)
  end
end

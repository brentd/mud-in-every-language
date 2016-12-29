require "pty"

class TestServer
  attr_reader :port, :thread

  CTRL_C_CODE = ?\C-c
  DEBUG_MODE_SIGNAL = "USR1"

  def initialize(port:, project_dir: "ruby", debug_regexp: nil, log: StringIO.new, command: "start")
    @port = port
    @project_dir = project_dir
    @log = log
    @debug_regexp = debug_regexp
    @command = command
  end

  def start
    r, w, @pid = PTY.spawn(@command)

    # Block until the server has started
    r.each do |line|
      @log << "[SERVER] ".red + line
      break if line =~ /^Server running/
    end

    reader = Thread.new do
      begin
        r.each do |line|
          if line.no_color =~ @debug_regexp
            puts "Debug mode matched; handing io to the server...\n"
            puts line
            replace_with_server(r, w)
          else
            @log << "[SERVER] ".red + line
          end
        end
      rescue Errno::EIO
      end
    end
    reader.abort_on_exception = true

    # Have the main thread wait on the reader thread when
    # we hand stdout/stdin over to it.
    Signal.trap(DEBUG_MODE_SIGNAL) do
      reader.join
    end
  end

  def stop
    Process.kill("SIGTERM", @pid) rescue nil
  end

  def replace_with_server(r, w)
    old_state = `stty -g`

    Process.kill(DEBUG_MODE_SIGNAL, Process.pid)
    system "stty -echo raw lnext ^_"

    reader = Thread.current
    writer = Thread.new do
      while c = STDIN.getc.chr
        if c == CTRL_C_CODE
          reader.raise Interrupt
        else
          w.print c
          w.flush
        end
      end
    end
    writer.abort_on_exception = true

    begin
      while c = r.readpartial(512)
        STDOUT.print c
        STDOUT.flush
      end
    rescue Errno::EIO, EOFError
    ensure
      writer.kill
      system "stty #{old_state}"; puts
    end
  end
end

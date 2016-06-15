require 'socket'
require 'optparse'

options = {
  port: 2000
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby server.rb [options]"

  opts.on("-pPORT", "--port=PORT", "Port to listen for TCP connections") do |p|
    options[:port] = p
  end

  opts.on("-t", "--test-mode", "Run in test mode") do
    options[:test_mode] = true
  end
end.parse!

server = TCPServer.new options[:port].to_i

puts "Server running on 0.0.0.0 port #{options[:port]}"

loop do
  Thread.start(server.accept) do |client|
    client.puts "What is your name, wanderer?"
    name = client.gets.strip
    client.puts "Did I hear that right, #{name}?"
    answer = client.gets.strip

    if answer =~ /^y/i
      client.puts "Give me a password for #{name}"
    else
      raise 'NOOO'
    end

    password = client.gets
    client.puts "Welcome to Aeon, #{name}"
  end
end

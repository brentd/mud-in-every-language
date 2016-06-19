require "socket"
require "optparse"

options = {
  port: 2000,
  test_mode: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby server.rb [options]"

  opts.on("-pPORT", "--port=PORT", "Port to listen for TCP connections") do |p|
    options[:port] = p.to_i
  end

  opts.on("-t", "--test-mode", "Run in test mode") do
    options[:test_mode] = true
  end
end.parse!

TEST_MODE = options[:test_mode]

server = TCPServer.new(options[:port])

puts "Server running on 0.0.0.0 port #{options[:port]}"

require "yaml/store"

if !TEST_MODE
  Store = YAML::Store.new(File.expand_path('../db.yml', __FILE__), true)
else
  file = File.expand_path('../test.yml', __FILE__)
  File.truncate(file, 0) rescue nil
  Store = YAML::Store.new(file)
end

Store.transaction do
  Store["users"] ||= []
end

require "pry"

module ClientMixin
  class ClientDisconnected < StandardError; end

  def gets
    s = super
    raise ClientDisconnected if s.nil? && closed?
    s
  end
end

Thread.abort_on_exception = true

loop do
  Thread.start(server.accept) do |socket|
    socket.extend(ClientMixin)
    client = socket

    client.puts "What is your name, wanderer?"
    name = client.gets.rstrip

    user = Store.transaction(true) {
      Store["users"].detect { |u| u["name"] == name }
    }

    if user
      client.print "Password:"
      password = client.gets.strip

      if user[:password] == password
        client.puts "Welcome back, #{name}"
      end
    else
      client.puts "Did I hear that right, #{name}?"
      answer = client.gets.strip

      if answer =~ /^y/i
        client.puts "Give me a password for #{name}"
        password = client.gets.strip

        Store.transaction do
          Store["users"] << {name: name, password: password}
        end

        client.puts "Welcome, #{name}"
      else
        raise "go back to login"
      end
    end
  end
end

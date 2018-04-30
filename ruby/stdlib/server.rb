require "socket"
require "optparse"
require "pathname"

options = {
  port: 2000,
  db_path: Pathname.new(File.expand_path("../db.yml", __FILE__))
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby server.rb [options]"

  opts.on("-p PORT", "--port=PORT", "Port to listen for TCP connections") do |p|
    options[:port] = p.to_i
  end

  opts.on("-d PATH", "--db=PATH", "Create or use the database file at PATH") do |path|
    options[:db_path] = Pathname.new(path)
  end

  opts.on("-l FILE", "--load=FILE", "Load the database with initial data from a JSON file") do |path|
    options[:load] = Pathname.new(path)
  end
end.parse!

server = TCPServer.new(options[:port])

puts "Server running on 0.0.0.0 port #{options[:port]}"

require "yaml/store"

Store = YAML::Store.new(options[:db_path], true)

Store.transaction do
  Store["users"] ||= []
end

require "pry"

module ClientMixin
  class ClientDisconnected < IOError; end

  def gets
    super.tap do |s|
      raise ClientDisconnected if s.nil?
    end.rstrip
  end
end

loop do
  Thread.start(server.accept) do |socket|
    begin
      Thread.current.abort_on_exception = true

      socket.extend(ClientMixin)
      client = socket

      client.puts "What is your name, wanderer?"
      name = client.gets.strip

      user = Store.transaction(true) {
        Store["users"].detect { |u| u[:name] == name }
      }

      if user
        attempt = 1
        loop do
          client.puts "Password:"
          password = client.gets.strip

          if user[:password] == password
            client.puts "Welcome back, #{name}"
            break
          else
            if attempt < 3
              attempt += 1
              redo
            else
              client.puts "Too many failed login attempts."
              client.close
              break
            end
          end
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
          # raise "go back to login"
        end
      end
    rescue ClientMixin::ClientDisconnected
    rescue Errno::EIO, Errno::EPIPE, EOFError
    end
  end
end

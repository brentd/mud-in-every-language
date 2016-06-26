require "socket"
require "optparse"

options = {
  port: 2000
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby server.rb [options]"

  opts.on("-pPORT", "--port=PORT", "Port to listen for TCP connections") do |p|
    options[:port] = p.to_i
  end
end.parse!

server = TCPServer.new(options[:port])

puts "Server running on 0.0.0.0 port #{options[:port]}"

require "yaml/store"

Store = YAML::Store.new(File.expand_path('../db.yml', __FILE__), true)

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
      name = client.gets

      user = Store.transaction(true) {
        Store["users"].detect { |u| u[:name] == name }
      }

      if user
        attempt = 1
        loop do
          client.puts "Password:"
          password = client.gets

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
        answer = client.gets

        if answer =~ /^y/i
          client.puts "Give me a password for #{name}"
          password = client.gets

          Store.transaction do
            Store["users"] << {name: name, password: password}
          end

          client.puts "Welcome, #{name}"
        else
          raise "go back to login"
        end
      end
    rescue ClientMixin::ClientDisconnected
    end
  end
end

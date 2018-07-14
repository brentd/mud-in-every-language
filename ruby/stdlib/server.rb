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

  opts.on("-l FILE", "--load=FILE", "Load the database with initial data from a YAML file") do |path|
    options[:load] = Pathname.new(path)
  end
end.parse!

server = TCPServer.new("0.0.0.0", options[:port])

puts "Server running on 0.0.0.0:#{options[:port]}"


require "yaml/store"

Store = YAML::Store.new(options[:db_path], true)


if options[:load]
  data = YAML.load(options[:load].read)
  Store.transaction do
    data.each do |key, value|
      Store[key] = value
    end
  end
end

# Initialize some properties in the store we expect to be available
Store.transaction do
  Store["config"] ||= {}
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


class Room
  attr_reader :title, :description

  def self.default_room
    new("The Void", "You don't think that you are not floating in nothing.")
  end

  def initialize(title, description)
    @title = title
    @description = description
  end
end

def find_room(player)
  room_id = player["room"]
  if room_id && room = Store.transaction(true) { Store["rooms"].detect { |r| r["id"] == room_id } }
    return Room.new(room["title"], room["description"])
  else
    return Room.default_room
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
        Store["users"].detect { |u| u["name"] == name }
      }

      if user
        attempt = 1
        loop do
          client.puts "Password:"
          password = client.gets.strip

          if user["password"] == password
            client.puts "Welcome back, #{name}."
            room = find_room(user)

            client.puts room.title
            client.puts "  #{room.description}"

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

          starting_room = Store.transaction(true) { Store["config"]["starting_room"] }
          user = {"name" => name, "password" => password, "room" => starting_room }

          Store.transaction do
            Store["users"] << user
          end

          client.puts "Welcome, #{name}."

          room = find_room(user)

          client.puts room.title
          client.puts "  #{room.description}"
        else
          # raise "go back to login"
        end
      end
    rescue ClientMixin::ClientDisconnected
    rescue Errno::EIO, Errno::EPIPE, EOFError
    end
  end
end

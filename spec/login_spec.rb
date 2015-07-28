require 'spec_helper'
require "minitest/autorun"

describe "Accepting TCP Connections" do
  it "should run on the port specified with -p" do
    @server = ServerRunner.new(port: 12345)
    @server.start
    TCPSocket.open('0.0.0.0', 12345)
  end
end

describe "Login" do
  include Assertions

  def self.test_order
    :sorted
  end

  before do
    @server = ServerRunner.new(port: 2000)
    @server.start
    @client = TestClient.new(port: 2000)
    @client.connect
  end

  after(:all) do
    @server.stop
  end

  it "prompts for a name upon connection" do
    assert_displayed "What is your name, wanderer?"
    @client.disconnect
    @client.connect
    assert_displayed "What is your name, wanderer?"
  end

  it "recognizes a new name" do
    assert_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    assert_displayed "Did I hear that right, Ethrin?"
  end

  it "allows canceling character creation" do
    assert_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    assert_displayed "Did I hear that right, Ethrin?"
    @client.input "y"
    assert_displayed "Give me a password for Ethrin"
    @client.input "s3kr3t"
    assert_displayed(/welcome to/i)
  end

  it "allows setting a password" do
    assert_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    assert_displayed "Did I hear that right, Ethrin?"
    @client.input "y"
    assert_displayed "Give me a password for Ethrin"
    @client.input "s3kr3t"
    assert_displayed(/welcome to/i)
  end

  it "persists the created user and allows reconnecting" do
    assert_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    @client.input "y"
    @client.input "s3kr3t"

    @client.disconnect
    @client.connect

    @client.input "Ethrin"
    assert_displayed "Password:"
    @client.input "s3kr3t"
    assert_displayed(/welcome back/i)
  end

  it "re-prompts for the password given an incorrect attempt"

  it "it disconnects the client after 3 failed password attempts"
end

describe "--test-mode" do
  it "delets the databse given the signal"
end

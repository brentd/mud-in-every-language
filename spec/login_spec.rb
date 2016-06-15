describe "Login" do
  before do
    @server = TestServer.new(port: 6000)
    @server.start
    @client = TestClient.new(port: 6000)
    @client.connect
  end

  after do
    @server.stop
  end

  it "prompts for a name upon connection" do
    expect_displayed "What is your name, wanderer?"
    @client.disconnect
    @client.connect
    expect_displayed "What is your name, wanderer?"
  end

  it "recognizes a new name" do
    expect_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    expect_displayed "Did I hear that right, Ethrin?"
  end

  it "allows canceling character creation" do
    expect_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    expect_displayed "Did I hear that right, Ethrin?"
    @client.input "y"
    expect_displayed "Give me a password for Ethrin"
    @client.input "s3kr3t"
    expect_displayed(/welcome to/i)
  end

  it "allows setting a password" do
    expect_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    expect_displayed "Did I hear that right, Ethrin?"
    @client.input "y"
    expect_displayed "Give me a password for Ethrin"
    @client.input "s3kr3t"
    expect_displayed(/welcome to/i)
  end

  it "persists the created user and allows reconnecting" do
    expect_displayed "What is your name, wanderer?"
    @client.input "Ethrin"
    @client.input "y"
    @client.input "s3kr3t"

    @client.disconnect
    @client.connect

    @client.input "Ethrin"
    expect_displayed "Password:"
    @client.input "s3kr3t"
    expect_displayed(/welcome back/i)
  end

  it "re-prompts for the password given an incorrect attempt"

  it "it disconnects the client after 3 failed password attempts"
end

describe "--test-mode" do
  it "delets the databse given the signal"
end

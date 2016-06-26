describe "Login" do
  before { client.connect }

  it "prompts for a name upon connection" do
    » "What is your name, wanderer?"
    client.reconnect
    » "What is your name, wanderer?"
  end

  it "recognizes a new name" do
    » "What is your name, wanderer?"
    « "Ethrin"
    » "Did I hear that right, Ethrin?"
  end

  it "allows character creation" do
    » "What is your name, wanderer?"
    « "Ethrin"
    » "Did I hear that right, Ethrin?"
    « "y"
    » "Give me a password for Ethrin"
    « "s3kr3t"
    »(/welcome/i)
  end

  it "allows canceling character creation" do
    skip
    » "What is your name, wanderer?"
    « "Ethrin"
    » "Did I hear that right, Ethrin?"
    « "n"
    » "What is your name, wanderer?"
  end

  it "persists the created character and allows reconnecting" do
    » "What is your name, wanderer?"
    « "Ethrin"
    « "y"
    « "s3kr3t"

    client.reconnect

    » "What is your name, wanderer?"
    « "Ethrin"
    » "Password:"
    « "s3kr3t"
    »(/welcome back/i)
  end

  it "re-prompts for the password given an incorrect attempt" do
    » "What is your name, wanderer?"
    « "Ethrin"
    « "y"
    « "s3kr3t"

    client.reconnect

    » "What is your name, wanderer?"
    « "Ethrin"
    » "Password:"
    « "wrong"
    » "Password:"
    « "s3kr3t"
    »(/welcome back/i)
  end

  it "it disconnects the client after 3 failed password attempts" do
    » "What is your name, wanderer?"
    « "Ethrin"
    « "y"
    « "s3kr3t"

    client.reconnect

    » "What is your name, wanderer?"
    « "Ethrin"
    » "Password:"
    « "wrong"
    » "Password:"
    « "wrong again"
    » "Password:"
    « "wrongggg"

    expect(client).to be_disconnected
  end
end

describe "--test-mode" do
  it "delets the databse given the signal"
end

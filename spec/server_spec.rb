describe "Accepting TCP Connections" do
  it "should run on the port specified with -p" do
    expect { client.connect }.to_not raise_error
  end
end

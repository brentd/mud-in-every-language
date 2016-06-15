describe "Accepting TCP Connections" do
  it "should run on the port specified with -p" do
    @server = TestServer.new(port: 12345)
    @server.start
    @client = TestClient.new(port: 12345)
    @client.connect
  end
end

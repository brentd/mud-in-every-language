require "assertions"

module MudInEveryLanguage
  module Spec
    class Case < Minitest::Spec
      include Assertions

      def self.test_order
        :alpha
      end

      def self.server=(server)
        @@server = server
      end

      def server
        @@server
      end

      def load(name)
        @init_path = File.expand_path("../../spec/data/#{name}.yml", __FILE__)
      end

      def start_server
        server.start(db_path: Tempfile.new('db').path, init_path: @init_path)
      end

      # Lazy getter - the first time during the test that `client` is accessed,
      # the server is started and the client connects.
      def client
        @client ||= begin
          start_server
          TestClient.new(port: server.port).connect
        end
      end

      after do
        server.stop
      end
    end

    class Builder
      attr_reader :spec, :server

      def initialize(server, spec: Class.new(MudInEveryLanguage::Spec::Case))
        spec.server = server
        @spec = spec
      end

      def call(title, lines, skip: false, data: nil)
        spec.it(title) do
          lines.each do |line|
            eval_str = case line
              when AssertionLine
                "assert_client_displayed(#{line.quoted})"
              when InputLine
                "client << #{line.quoted}"
              when RubyLine
                line
            end
            instance_eval(eval_str, "spec/login_test", line.location)
          end
        end
      end
    end
  end
end

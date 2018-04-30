require "assertions"

module MudInEveryLanguage
  module Spec
    class Case < Minitest::Spec
      include Assertions

      def self.test_order
        :alpha
      end
    end

    class Builder
      attr_reader :spec, :server

      def initialize(server, spec: Class.new(MudInEveryLanguage::Spec::Case))
        @server = server
        @spec = spec
      end

      def call(title, lines, skip: false, data: nil)
        server = @server

        spec.let(:server) { server }
        spec.let(:client) { TestClient.new(port: server.port) }

        spec.before do
          server.start(db_path: Tempfile.new('db').path)
        end

        spec.after do
          server.stop
        end

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

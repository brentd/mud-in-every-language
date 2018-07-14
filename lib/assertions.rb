module MudInEveryLanguage
  module Spec
    module Assertions
      def assert_client_displayed(expected)
        matched = false
        timeout = 1

        reader = Thread.new do
          Thread.current.abort_on_exception = true
          client.each_line do |line|
            matched = expected == line.rstrip
            break if matched
          end
        end

        begin
          reader.join(timeout)
        ensure
          reader.kill
        end

        unless matched
          assert(matched, "Missing: #{expected}".red + pretty_log)
        end
      end

      def assert_client_disconnected
        assert(!client.connected?, "Expected the client to be disconnected." + pretty_log)
      end

      def pretty_log
        border = "------------- LOG -------------"
        log = [border, client.log.string, '-' * border.length].join("\n")
        "\n#{log}\n"
      end
    end
  end
end

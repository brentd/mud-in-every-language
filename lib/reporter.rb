module MudInEveryLanguage
  module Spec
    class Reporter < Minitest::StatisticsReporter
      def initialize(*)
        super
        @failure_titles = []
      end

      def record(result)
        super
        title = result.name.sub(/test_\d{4}_/, '')

        if result.passed?
          io.puts "✓ #{title}".green
        else
          location = result.failure.location
          @failure_titles << failure_title = "✗ #{title}".red + " - #{location}"

          io.puts
          io.puts failure_title
          io.puts
          io.puts result.failure.message.gsub(/^(?!$)/, "\t")
          io.puts
        end
      end

      def report
        super
        summary = "Finished in %.2fs" % [total_time]
        stats   = "#{count} tests: #{failures} failures."
        io.puts "\n#{summary} - #{failures == 0 ? stats.green : stats.red}\n"
        @failure_titles.each { |f| io.puts f }
      end
    end
  end
end

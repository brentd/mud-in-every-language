module MudInEveryLanguage
  module Spec
    class Reporter < Minitest::StatisticsReporter
      def record(result)
        super
        title = result.name.sub(/test_\d{4}_/, '')

        if result.passed?
          io.puts "✓ ".green + title
        else
          location = result.failure.location
          io.puts
          io.puts "✗ #{title}".red + " - #{location}"
          io.puts
          io.puts result.failure.message.gsub(/^(?!$)/, "\t")
          io.puts
        end
      end

      def report
        super
        summary = "Finished in %.2fs" % [total_time]
        stats   = "#{count} tests, #{failures} failures"
        io.puts "\n#{summary} - #{stats}"
      end
    end
  end
end

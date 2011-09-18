module Guard
  class Jessie
    class Runner
      def initialize
        @files = {}
      end

      def run(paths)
        fs = @files[paths.first] if paths.size == 1
        command = jessie_command(paths)
        output = run_command(command)
        fs = handle_results(output, fs)
        @files[paths.first] = fs if fs and paths.size == 1
      end

    private
      def jessie_command(paths)
        cmd_parts = []
        cmd_parts << "jessie"
        cmd_parts << "-f progress"
        cmd_parts << paths.join(" ")
        cmd_parts.join(" ")
      end

      def run_command(command)
        `#{command} 2>&1`
      end

      def handle_results(output, fs)
        lines = output.split(/\n/)
        result = lines.last.gsub(/\e\[\d+m/, "").strip  # remove coloring
        if m = result.match(/^(\d+) examples?(?:, (\d+) failures?)?$/)
          num_examples, num_failed = m[1].to_i, m[2].to_i
          num_passed = num_examples - num_failed
          title = "Jasmine results"
          if num_failed > 0
            message = "#{num_failed} example#{'s' if num_failed != 1} failed"
            if fs
              diff = num_failed - fs[:num_failed]
              message << " (#{diff > 0 ? '+' : '-'}#{diff.abs})" if diff != 0
            end
            Notifier.failure(title, message)
            puts output
          elsif num_passed > 0
            message = "#{num_examples} example#{'s' if num_examples != 1} passed"
            if fs
              diff = num_passed - fs[:num_passed]
              message << " (#{diff > 0 ? '+' : '-'}#{diff.abs})" if diff != 0
            end
            Notifier.success(title, message)
          end
          return {:num_passed => num_passed, :num_failed => num_failed}
        else
          puts output
          return nil
        end
      end
    end
  end
end

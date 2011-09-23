module Guard
  class Jessie
    class Runner
      def initialize
        @files = {}
      end

      def run(paths)
        running_one_file = (paths.size == 1 or paths[0] =~ /\.[^.]+$/)
        fs = @files[paths.first] if running_one_file
        command = jessie_command(paths)
        output = run_command(command)
        fs = handle_results(output, fs)
        @files[paths.first] = fs if fs and running_one_file
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

      def handle_results(original_output, fs)
        output = original_output.gsub(/\e\[\d+m/, "").strip  # remove coloring
        lines = output.split(/\n/)

        if lines[0] =~ /Jessie failed to start/
          if m = lines[1].match(/^[^:]+: .+$/)
            Notifier.failure("Jessie error", lines[1], :to => :growl)
          end
          puts original_output
          return
        end

        result = lines[-1]
        if m1 = result.match(/(\d+) examples?/)
          num_examples = m1[1].to_i
        else
          num_examples = 0
        end
        if m2 = result.match(/(\d+) failures?/)
          num_failed = m2[1].to_i
        else
          num_failed = 0
        end
        if m3 = result.match(/(\d+) pending/)
          num_pending = m3[1].to_i
        else
          num_pending = 0
        end
        if m1 or m2 or m3
          num_passed = num_examples - num_failed - num_pending
          title = "Jasmine results"
          if num_failed > 0
            message = "#{num_failed} example#{'s' if num_failed != 1} failed"
            if fs
              diff = num_failed - fs[:num_failed]
              message << " (#{diff > 0 ? '+' : '-'}#{diff.abs})" if diff != 0
            end
            Notifier.failure(title, message, :to => [:stdio, :growl])
            puts original_output
          elsif num_passed > 0
            message = "#{num_passed} example#{'s' if num_passed != 1} passed"
            if fs
              diff = num_passed - fs[:num_passed]
              message << " (#{diff > 0 ? '+' : '-'}#{diff.abs})" if diff != 0
            end
            if num_pending > 0
              message << "\n(#{num_pending} others #{num_pending == 1 ? 'is' : 'are'} pending)"
            end
            Notifier.success(title, message, :to => [:stdio, :growl])
          elsif num_pending > 0
            Notifier.pending(title, "All examples are pending", :to => [:stdio, :growl])
          end
          return {:num_passed => num_passed, :num_failed => num_failed}
        end

        puts original_output
        return nil
      end
    end
  end
end

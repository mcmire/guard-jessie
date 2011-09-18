module Guard
  class Jessie
    module Runner
      class << self
        def run(paths)
          return false if paths.empty?
          run_command(jessie_command(paths))
        end

        private
          def run_command(command)
            output = `#{command} 2>&1`
            lines = output.split(/\n/)
            result = lines.last.gsub(/\e\[\d+m/, "").strip  # remove coloring
            if m = result.match(/^(\d+) examples?(?:, (\d+) failures?)?$/)
              num_examples, num_failed = m[1].to_i, m[2].to_i
              title = "Jasmine results"
              if num_failed > 0
                message = "#{num_failed} example#{'s' if num_failed != 1} failed"
                Notifier.failure(title, message)
                puts output
              else
                message = "#{num_examples} example#{'s' if num_examples != 1} passed"
                Notifier.success(title, message)
              end
            else
              puts output
            end
          end

          def jessie_command(paths)
            cmd_parts = []
            cmd_parts << "jessie"
            cmd_parts << "-f progress"
            cmd_parts << paths.join(" ")
            cmd_parts.join(" ")
          end
      end
    end
  end
end

require 'guard/notifier'

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
              num_passed, num_failed = m[1].to_i, m[2].to_i
              num_examples = num_passed + num_failed
              message = "#{num_passed} of #{num_examples} examples passed"
              if num_failed > 0
                Notifier.notify(message, :title => "Jessie results", :image => :failed)
                puts output
              else
                Notifier.notify(message, :title => "Jessie results", :image => :success)
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

require 'guard/notifier'

module Guard
  class Jessie
    module Notifier
      class << self
        def success(title, message)
          notify(title, message, :success)
        end

        def failure(title, message)
          notify(title, message, :failed)
        end

        private
          def notify(title, message, status)
            color = (status == :success) ? 32 : 31
            puts "\e[#{color}m#{title}: #{message}\e[0m"
            ::Guard::Notifier.notify(message, :title => "Jasmine results", :image => status)
          end
      end
    end
  end
end

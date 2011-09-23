require 'guard/notifier'

module Guard
  class Jessie
    module Notifier
      class << self
        def success(title, message, options={})
          notify(title, message, :success, options)
        end

        def failure(title, message, options={})
          notify(title, message, :failed, options)
        end

        def pending(title, message, options={})
          notify(title, message, :pending, options)
        end

        private
          def notify(title, message, status, options)
            out = Array(options[:to] || [])
            color = (status == :success) ? 32 : 31
            if out.include?(:stdio)
              puts "\e[#{color}m#{title}: #{message.gsub(/\n/, " ").squeeze(" ")}\e[0m"
            end
            if out.include?(:growl)
              ::Guard::Notifier.notify(message, :title => title, :image => status)
            end
          end
      end
    end
  end
end

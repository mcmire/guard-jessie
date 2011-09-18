require 'guard'
require 'guard/guard'

module Guard
  class Jessie < Guard
    autoload :Notifier, 'guard/jessie/notifier'
    autoload :Runner,   'guard/jessie/runner'

    def initialize(*args)
      super
      @runner = Runner.new
    end

    def run_all
      info "Jessie: Running all specs"
      @runner.run %w[spec]
    end

    def run_on_change(paths)
      paths = paths.select {|path| File.exists?(path) }
      if paths.any?
        info "Jessie: Running #{paths.join(", ")}"
        @runner.run(paths)
      end
    end

  private
    def info(msg)
      puts "\e[33m#{msg}\e[0m"
    end
  end
end


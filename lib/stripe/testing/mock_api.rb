module Stripe
  module MockAPI
    class << self

      # TODO - would have to figure out something else for threaded parallelization
      def current_session
        session_pool[Process.pid]
      end
      alias start current_session

      private

        def session_pool
          @session_pool ||= Hash.new do |hash, name|
            hash[name] = Stripe::MockAPI::Session.new
          end
        end
    end

    class Session
      attr_accessor :server_pid, :server_port

      def initialize
        puts "Starting stripe-mock..."

        @stdout, @child_stdout = ::IO.pipe
        @stderr, @child_stderr = ::IO.pipe

        self.server_pid = ::Process.spawn ["stripe-mock", "stripe-mock"],
                                          "-http-port", "0", # tells stripe-mock to select a port
                                          out: @child_stdout,
                                          err: @child_stderr

        [@child_stdout, @child_stderr].each(&:close)

        # find port in "Listening for HTTP on port: 50602" from stripe-mock
        buffer = ""
        loop do
          buffer += @stdout.readpartial(4096)

          if (matches = buffer.match(/ port: (\d+)/))
            self.server_port = matches[1]
            break
          end

          sleep(0.1)
        end

        status = (::Process.wait2(server_pid, ::Process::WNOHANG) || []).last
        if status.nil?
          puts("Started stripe-mock; PID = #{server_pid}, port = #{server_port}")
          setup_exit_handler
        else
          abort("stripe-mock terminated early: #{status}")
        end
      end

      def stop
        return if server_pid.nil?

        puts("Stopping stripe-mock...")

        ::Process.kill(:SIGTERM, server_pid)
        ::Process.waitpid2(server_pid)

        puts("Stopped stripe-mock")

      ensure
        self.server_pid = nil
        self.server_port = nil
      end

      private

        def setup_exit_handler
          main = Process.pid

          at_exit do
            # store the exit status of the test run
            exit_status = $ERROR_INFO.status if $ERROR_INFO.is_a?(SystemExit)

            stop if Process.pid == main # TODO - it's not obvious to me when this wouldn't be true...?
            exit exit_status if exit_status # force exit with stored status
          end
        end
    end
  end
end

require 'yaml'

module Crabgrass
  module Deprecation #:nodoc:
    mattr_accessor :debug
    self.debug = false

    # Choose the default warn behavior according to RAILS_ENV.
    # Ignore deprecation warnings in production.
    DEFAULT_BEHAVIORS = {
      'test'        => Proc.new { |message, callstack|
                         $stderr.puts(message)
                         $stderr.puts callstack.join("\n  ") if debug
                       },
      'development' => Proc.new { |message, callstack|
                         logger = defined?(::RAILS_DEFAULT_LOGGER) ? ::RAILS_DEFAULT_LOGGER : Logger.new($stderr)
                         logger.warn message
                         logger.debug callstack.join("\n  ") if debug
                       }
    }

    class << self
      def warn(message = nil, callstack = caller)
        behavior.call(deprecation_message(callstack, message), callstack) if behavior && !silenced?
      end

      def default_behavior
        if defined?(RAILS_ENV)
          DEFAULT_BEHAVIORS[RAILS_ENV.to_s]
        else
          DEFAULT_BEHAVIORS['test']
        end
      end

      # Have deprecations been silenced?
      def silenced?
        @silenced = false unless defined?(@silenced)
        @silenced
      end

      # Silence deprecation warnings within the block.
      def silence
        old_silenced, @silenced = @silenced, true
        yield
      ensure
        @silenced = old_silenced
      end

      attr_writer :silenced


      private
        def deprecation_message(callstack, message = nil)
          message ||= "You are using deprecated behavior which will be removed soon."
          "DEPRECATION WARNING: #{message}. #{deprecation_caller_message(callstack)}"
        end

        def deprecation_caller_message(callstack)
          file, line, method = extract_callstack(callstack)
          if file
            if line && method
              "(called from #{method} at #{file}:#{line})"
            else
              "(called from #{file}:#{line})"
            end
          end
        end

        def extract_callstack(callstack)
          if md = callstack.first.match(/^(.+?):(\d+)(?::in `(.*?)')?/)
            md.captures
          else
            callstack.first
          end
        end
    end

    # Behavior is a block that takes a message argument.
    mattr_accessor :behavior
    self.behavior = default_behavior

    # Warnings are not silenced by default.
    self.silenced = false

    # Stand-in for @request, @attributes, @params, etc which emits deprecation
    # warnings on any method call (except #inspect).
    class DeprecatedInstanceVariableProxy #:nodoc:
      silence_warnings do
        instance_methods.each { |m| undef_method m unless m =~ /^__/ }
      end

      def initialize(instance, method, var = "@#{method}")
        @instance, @method, @var = instance, method, var
      end

      # Don't give a deprecation warning on inspect since test/unit and error
      # logs rely on it for diagnostics.
      def inspect
        target.inspect
      end

      private
        def method_missing(called, *args, &block)
          warn caller, called, args
          target.__send__(called, *args, &block)
        end

        def target
          @instance.__send__(@method)
        end

        def warn(callstack, called, args)
          Crabgrass::Deprecation.warn("#{@var} is deprecated! Call #{@method}.#{called} instead of #{@var}.#{called}. Args: #{args.inspect}", callstack)
        end
    end
  end
end

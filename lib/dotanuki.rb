require 'posix/spawn'

# Module intented to be included into classes which execute system commands
# @author Martin Englund
module Dotanuki

  # Error raised when an execution error occurs
  class ExecError < StandardError
    # Create a new ExecError
    #
    # @param [String] message error message
    def initialize(message)
      super(message)
    end
  end

  # Result of one or more command executions
  class ExecResult

    # Array of stdout from each command executed
    # @return [Array]
    attr_reader :stdout

    # Array of stderr from each command executed
    # @return [Array]
    attr_reader :stderr

    # Exit status of the command that failed, nil if the command was not found
    # and 0 if all commands succeeded
    #
    # @return [Fixnum]
    attr_reader :status

    # Index of the command that failed, or nil if all commands succeeded
    # @return [Fixnum]
    attr_reader :failed_index

    def initialize
      @stdout = []
      @stderr = []
      @status = 0
      @failed_index = nil
    end

    # Returns true if a command has failed
    def failed?
      status != 0
    end

    # Returns stderr for the command that failed
    def fail_message
      stderr[@failed_index]
    end

    # Add the result of a command execution
    def add(stdout, stderr, status)
      @stdout << stdout
      @stderr << stderr
      if status.nil? || status != 0
        @status = status
        @failed_index = @stdout.size - 1
      end
    end

    # Add another [ExecResult] to this
    def <<(result)
      raise ArgumentError unless result.is_a?(ExecResult)
      # TODO merge correctly
      add(result.stdout, result.stderr, result.status)
    end
  end

  # Default options for executing commands
  DEFAULT_OPTIONS = {:on_error => :exception}

  # @param [Hash] options the options for error handling
  # @option options [Symbol] :on_error How to handle errors,
  #   can be either `:exception` or `:silent`
  def initialize(options={})
    @defaults = DEFAULT_OPTIONS.merge(options)
  end

  # Execute commands wrapped in a block
  #
  # @param [Hash] options (see #guard)
  # @return [ExecResult]
  # @example
  #   guard do
  #     execute "uname -a"
  #     execute "ls /does/not/exist"
  #   end
  # @note this method isn't thread safe
  # @todo pass an environment too
  def guard(options={}, &block)
    # if guard is called as a module function @defaults is not set
    opts = (@defaults || {}).merge(options)
    validate_options(opts)
    # TODO this is not thread safe
    @guard = ExecResult.new
    yield
    clear_guard
  rescue ExecError => e
    result = clear_guard
    raise e if opts[:on_error] == :exception
    result
  end

  # Execute one or more commands
  #
  # @param [String, Array] commands string or array containing the command to be executed
  # @param [Hash] options (see #guard)
  # @return [ExecResult]
  # @todo pass an environment too
  def execute(commands, options={})
    validate_options(options)

    result = ExecResult.new

    [commands].flatten.each do |command|
      begin
        child = POSIX::Spawn::Child.new(command)
        stdout = child.out.strip
        stderr = child.err.strip
        result.add(stdout, stderr, child.status.exitstatus)

        if child.status.exitstatus != 0
          if options[:on_error] == :exception || @guard
            @guard << result if @guard
            raise ExecError, stderr
          end
          break
        end
      rescue Errno::ENOENT
        result.add(nil, nil, nil)
        if options[:on_error] == :exception
          @guard << result if @guard
          raise ExecError, "#{command}: command not found"
        end
        break
      end
    end

    @guard << result if @guard

    return result
  end

  # Validates options for Dotanuki#execute or Dotanuki#guard
  #
  # @raise [ArgumentError] if an unknown option is given
  def validate_options(options)
    options.each do |option, value|
      if option == :on_error && ! [:exception, :silent].include?(value)
        raise ArgumentError, "illegal value for option #{option}: #{value}"
      end
      raise ArgumentError, "illegal option: #{option}" if option != :on_error
    end
  end

  # TODO this is not thread safe
  def clear_guard
    result = @guard
    @guard = nil
    result
  end

  # TODO don't expose validate_options & clear_guard
  module_function :execute, :guard, :validate_options, :clear_guard

end

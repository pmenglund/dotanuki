require 'popen4'

module Dotanuki

  # thrown when an execution error occurs
  class ExecError < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  # class for the result of an execution of one or more commands
  class ExecResult
    attr_reader :stdout, :stderr, :status, :failed_index
    def initialize
      @stdout = []
      @stderr = []
      @status = 0
      @failed_index = nil
    end

    # Returns true if the command has failed
    def failed?
      status != 0
    end

    # Returns stderr for the command that failed
    def fail_message
      stderr[@failed_index]
    end

    def add(stdout, stderr, status)
      @stdout << stdout
      @stderr << stderr
      @status = status
      if status.nil? || status != 0
        @failed_index = @stdout.size - 1
      end
    end

    def <<(result)
      raise ArgumentError unless result.is_a?(ExecResult)
      # TODO merge correctly
      add(result.stdout, result.stderr, result.status)
    end
  end

  # Execute commands in a block and return an array of ExecResult
  #
  # @example
  #   guard do
  #     execute "uname -a"
  #     execute "ls /does/not/exist"
  #   end
  #
  # TODO this is not thread safe
  def guard(options={}, &block)
    validate_options(options)
    @guard = ExecResult.new
    yield
    clear_guard
  rescue ExecError => e
    result = clear_guard
    raise e if options[:on_error] == :exception
    result
  end

  # commands can be a string or an array of strings
  def execute(commands, options={})
    validate_options(options)

    result = ExecResult.new

    [commands].flatten.each do |command|
      stdout, stderr, exit_status = _execute(command, options)
      result.add(stdout, stderr, exit_status)
      if options[:on_error] == :exception || @guard
        if exit_status.nil?
          @guard << result if @guard
          raise ExecError, "#{command}: command not found"
        elsif exit_status != 0
          @guard << result if @guard
          raise ExecError, stderr
        end
      elsif exit_status.nil? || exit_status != 0
        break
      end
    end
    @guard << result if @guard

    return result
  end

  def _execute(command, options={})
    stdout = stderr = ""

    status =
      POpen4::popen4(command) do |out, err, stdin, pid|
        stdout = out.read.chomp
        stderr = err.read.chomp
      end

    return stdout, stderr, status ? status.exitstatus : status
  end

  def validate_options(options)
    options.each do |option, value|
      if option == :on_error && value != :exception
        raise ArgumentError, "illegal value for option #{option}: #{value}"
      end
      raise ArgumentError, "illegal option: #{option}" if option != :on_error
    end
  end

  private

  def clear_guard
    result = @guard
    @guard = nil
    result
  end
end

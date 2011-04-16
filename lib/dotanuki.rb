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
    def initialize(out, err, status, failed_index=nil)
      @stdout = out
      @stderr = err
      @status = status
      @failed_index = failed_index
    end

    def failed?
      status != 0
    end

    def fail_message
      stderr[@failed_index]
    end
  end

  # commands can be a string or an array of strings
  def execute(commands, options={})
    validate_options(options)

    stdout = []
    stderr = []
    exit_status = 0
    failed = nil
    index = 0

    [commands].flatten.each do |command|
      out, err, ex = _execute(command, options)
      stdout << out
      stderr << err
      exit_status = ex
      if options[:on_error] == :exception
        if exit_status.nil?
          raise ExecError, "#{command}: command not found"
        elsif exit_status != 0
          raise ExecError, stderr[index]
        end
      elsif exit_status.nil? || exit_status != 0
        failed = index
        break
      end
      index += 1
    end

    return ExecResult.new(stdout, stderr, exit_status, failed)
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
end

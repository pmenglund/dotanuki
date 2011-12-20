require 'spec_helper'

describe Dotanuki do
  include Dotanuki

  NON_EXISTING_PATH = "/not/an/existing/program"
  COMMAND_NOT_FOUND = NON_EXISTING_PATH
  COMMAND_FAILED = "ls -d #{NON_EXISTING_PATH}"

  EXISTING_PATH = "/"
  EXISTING_COMMAND = "ls -d #{EXISTING_PATH}"

  describe "guard" do
    it "should collect all output" do
      guard do
        execute("id")
        execute("ls")
      end.stdout.size.should == 2
    end

    it "should stop when one item fails" do
      guard(:on_error => :silent) do
        execute("id")
        execute(COMMAND_FAILED)
        execute("uname -n")
      end.failed_index.should == 1
    end

    it "should raise an exception by default on error" do
      lambda { guard do
        execute(COMMAND_FAILED)
      end }.should raise_error
    end

    it "should not raise an exception on error when silent" do
      lambda { guard(:on_error => :silent) do
        execute(COMMAND_FAILED)
      end }.should_not raise_error
    end
  end

  describe "execute" do

    describe "missing command" do
      it "should stop on first" do
        r = execute([COMMAND_NOT_FOUND, EXISTING_COMMAND])
        r.failed_index.should == 0
      end

      it "should stop on last" do
        r = execute([EXISTING_COMMAND, COMMAND_NOT_FOUND])
        r.failed_index.should == 1
      end
    end

    describe "failing command" do

      it "should stop when the first fails" do
        r = execute([COMMAND_FAILED, "id", "id"])
        r.failed_index.should == 0
        r.status.should_not == 0
      end

      it "should stop on failure" do
        r = execute(["id", COMMAND_FAILED, "id"])
        r.failed_index.should == 1
        r.status.should_not == 0
      end

      it "should stop when the last fails" do
        r = execute(["id", "id", COMMAND_FAILED])
        r.failed_index.should == 2
        r.status.should_not == 0
      end

      it "should not return 0" do
        execute(COMMAND_FAILED).status.should_not == 0
      end

      it "should capture stderr" do
        r = execute(COMMAND_FAILED)
        r.stderr[0].should match /ls: .*#{NON_EXISTING_PATH}: No such file or directory/
      end

    end

    it "should return 0 when the command succeeds" do
      execute("ls -d /").status.should == 0
    end

    it "should execute all commands in an array" do
      r = execute(["id", "ls -d /", "id"])
      r.status.should == 0
      r.stdout.size.should == 3
      r.stderr.size.should == 3
    end

    it "should execute a single command" do
      r = execute("echo 'bar'")
      r.status.should == 0
      r.stdout.should == ["bar"]
      r.stderr.should == [""]
    end

    describe "with exception option should throw an exception" do
      it "on missing command" do
        lambda { execute(COMMAND_NOT_FOUND, {:on_error => :exception}) }.should raise_error Dotanuki::ExecError
      end

      it "exception failing" do
        lambda { execute(COMMAND_FAILED, {:on_error => :exception}) }.should raise_error Dotanuki::ExecError
      end
    end

    it "should raise an error on invalid options" do
      lambda { execute(COMMAND_NOT_FOUND, {:on_error => :asd}) }.should raise_error ArgumentError
    end

    it "should raise an error on invalid option argument" do
      lambda { execute(COMMAND_NOT_FOUND, {:asd => :asd}) }.should raise_error ArgumentError
    end

    it "should supply correct info on a failing command" do
      r = execute(COMMAND_FAILED)
      r.failed?.should be_true
      r.fail_message.should_not be_empty
    end
  end

end
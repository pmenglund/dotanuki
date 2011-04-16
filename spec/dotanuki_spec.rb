require 'spec_helper'

describe Dotanuki do

  class C
    include Dotanuki
  end
  
  before :all do
    @c = C.new
  end

  NON_EXISTING_PATH = "/not/an/existing/program"
  COMMAND_NOT_FOUND = NON_EXISTING_PATH
  COMMAND_FAILED = "ls -d #{NON_EXISTING_PATH}"

  EXISTING_PATH = "/"
  EXISTING_COMMAND = "ls -d #{EXISTING_PATH}"

  describe "execute" do
    
    describe "missing command" do
      it "should stop on first" do
        r = @c.execute([COMMAND_NOT_FOUND, EXISTING_COMMAND])
        r.failed_index.should == 0
      end

      it "should stop on last" do
        r = @c.execute([EXISTING_COMMAND, COMMAND_NOT_FOUND])
        r.failed_index.should == 1
      end

      it "should return nil when not found" do
        @c.execute([EXISTING_COMMAND, COMMAND_NOT_FOUND]).status.should be_nil
      end

      it "should return nil when not found" do
        @c.execute([COMMAND_NOT_FOUND, EXISTING_COMMAND]).status.should be_nil
      end
    end

    describe "failing command" do

      it "should stop when the first fails" do
        r = @c.execute([COMMAND_FAILED, "id", "id"])
        r.failed_index.should == 0
        r.status.should_not == 0
      end

      it "should stop on failure" do
        r = @c.execute(["id", COMMAND_FAILED, "id"])
        r.failed_index.should == 1
        r.status.should_not == 0
      end

      it "should stop when the last fails" do
        r = @c.execute(["id", "id", COMMAND_FAILED])
        r.failed_index.should == 2
        r.status.should_not == 0
      end

      it "should not return 0" do
        @c.execute(COMMAND_FAILED).status.should_not == 0
      end

      it "should capture stderr" do
        r = @c.execute(COMMAND_FAILED)
        r.stderr[0].should == "ls: #{NON_EXISTING_PATH}: No such file or directory"
      end

    end

    it "should return 0 when the command succeeds" do
      @c.execute("ls -d /").status.should == 0
    end
  
    it "should execute all commands in an array" do
      r = @c.execute(["id", "ls -d /", "id"])
      r.status.should == 0
      r.stdout.size.should == 3
      r.stderr.size.should == 3
    end
  
    it "should execute a single command" do
      r = @c.execute("echo 'bar'")
      r.status.should == 0
      r.stdout.should == ["bar"]
      r.stderr.should == [""]
    end
  
    it "should execute a single command" do
      @c._execute("echo 'foo'").should == ["foo", "", 0]
    end

    describe "with exception option should throw an exception" do
      it "on missing command" do
        lambda { @c.execute(COMMAND_NOT_FOUND, {:on_error => :exception}) }.should raise_error Dotanuki::ExecError, "#{NON_EXISTING_PATH}: command not found"
      end

      it "exception failing" do
        lambda { @c.execute(COMMAND_FAILED, {:on_error => :exception}) }.should raise_error Dotanuki::ExecError, "ls: #{NON_EXISTING_PATH}: No such file or directory"
      end
    end

    it "should raise an error on invalid options" do
      lambda { @c.execute(COMMAND_NOT_FOUND, {:on_error => :asd}) }.should raise_error ArgumentError
    end

    it "should raise an error on invalid option argument" do
      lambda { @c.execute(COMMAND_NOT_FOUND, {:asd => :asd}) }.should raise_error ArgumentError
    end

    it "should supply correct info on a failing command" do
      r = @c.execute("ls /asd")
      r.failed?.should be_true
      r.fail_message.should_not be_empty
    end
  end

end
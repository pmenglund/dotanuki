require 'spec_helper'

describe Dotanuki do
  it "should execute module function" do
    Dotanuki.execute("ls /").failed?.should be_false
  end

  describe "#guard" do
    it "should not raise exception" do
      lambda { Dotanuki.guard do
        Dotanuki.execute("ls /asd")
      end }.should_not raise_error Dotanuki::ExecError
    end

    it "should raise exception when told to" do
      lambda { Dotanuki.guard(:on_error => :exception) do
        Dotanuki.execute("ls /asd")
      end }.should raise_error Dotanuki::ExecError
    end
  end

end

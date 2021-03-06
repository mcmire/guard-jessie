require 'spec_helper'
module Guard
  describe Jessie do
    let(:paths) { %w[array of changed paths]}

    describe "#run_all" do
      it "runs all specs" do
        Jessie::Runner.should_receive(:run).with(["spec"])
        subject.run_all
      end
    end
    describe "#run_on_change" do
      it "runs changed files" do
        Jessie::Runner.should_receive(:run).with(paths)
        subject.run_on_change paths
      end
    end
  end
end

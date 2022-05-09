# frozen_string_literal: true

require 'spec_helper'
require 'scheduler'

describe Scheduler do
  let(:catcher) { spy("Test") }
  let(:scheduler) {
    Scheduler.new('test', 1, Logger.new(nil)) do
      catcher.run
    end
  }

  context 'on init' do
    it 'always runs' do
      expect(catcher).to receive(:run)
      scheduler.run
    end
  end

  context 'on the second run' do
    let(:time) { Time.now }
    before do
      scheduler.stub(:current_time).and_return(time)
    end
    
    it 'does not run before enough time has expired' do
      scheduler.run
      expect(catcher).not_to receive(:run)
      scheduler.run
    end

    it 'runs when enough time has expired' do
      scheduler.run
      scheduler.stub(:current_time).and_return(time+300)
      expect(catcher).to receive(:run)
      scheduler.run
    end
  end
end

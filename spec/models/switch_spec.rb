require 'spec_helper'

describe Switch do
  describe "on?" do
    it "should return true if true and false if false" do
      @switch1 = FactoryGirl.create(:switch, :switch_on => true)
      @switch2 = FactoryGirl.create(:switch, :switch_on => false)

      expect( @switch1.on?).to eq(true)
      expect(@switch2.on?).to eq(false)
    end
  end

  describe "on" do
    it "should set the switch to true (on)" do
      @switch = FactoryGirl.create(:switch, :switch_on => false)

      expect(@switch.on?).to eq(false)

      @switch.on

      expect(@switch.on?).to eq(true)
    end
  end

  describe "off" do
    it "should set the switch to false (off)" do
      @switch = FactoryGirl.create(:switch, :switch_on => true)

      expect(@switch.on?).to eq(true)

      @switch.off

      expect(@switch.on?).to eq(false)
    end
  end

  describe "self.maintenance_mode" do
    it "should return the maintenance_mode switch object" do
      FactoryGirl.create(:switch)
      switch = Switch.maintenance_mode
      expect(switch.switch).to eq("maintenance_mode")
    end
  end
end
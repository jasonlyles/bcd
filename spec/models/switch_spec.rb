require 'spec_helper'

describe Switch do
  describe "on?" do
    it "should return true if true and false if false" do
      @switch1 = FactoryGirl.create(:switch, :switch_on => true)
      @switch2 = FactoryGirl.create(:switch, :switch_on => false)

      @switch1.on?.should == true
      @switch2.on?.should == false
    end
  end

  describe "on" do
    it "should set the switch to true (on)" do
      @switch = FactoryGirl.create(:switch, :switch_on => false)

      @switch.on?.should == false

      @switch.on

      @switch.on?.should == true
    end
  end

  describe "off" do
    it "should set the switch to false (off)" do
      @switch = FactoryGirl.create(:switch, :switch_on => true)

      @switch.on?.should == true

      @switch.off

      @switch.on?.should == false
    end
  end

  describe "self.maintenance_mode" do
    it "should return the maintenance_mode switch object" do
      FactoryGirl.create(:switch)
      switch = Switch.maintenance_mode
      switch.switch.should == "maintenance_mode"
    end
  end
end
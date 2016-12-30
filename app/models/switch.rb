class Switch < ActiveRecord::Base
  attr_accessible :switch, :switch_on

  def on?
    switch_on
  end

  def off?
    !switch_on
  end

  def on
    self.switch_on = true
    self.save!
  end

  def off
    self.switch_on = false
    self.save!
  end

  def self.maintenance_mode
    uncached do
      self.find_by_switch('maintenance_mode')
    end
  end
end
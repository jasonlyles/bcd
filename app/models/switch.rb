# frozen_string_literal: true

class Switch < ApplicationRecord
  # attr_accessible :switch, :switch_on

  def on?
    switch_on
  end

  def off?
    !switch_on
  end

  def on
    self.switch_on = true
    save!
  end

  def off
    self.switch_on = false
    save!
  end

  def self.maintenance_mode
    uncached do
      find_by_switch('maintenance_mode')
    end
  end
end

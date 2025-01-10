# frozen_string_literal: true

class String
  def despace
    gsub(' ', '')
  end

  def to_snake_case
    downcase.gsub(' ', '_')
  end
end

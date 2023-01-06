# frozen_string_literal: true

module PartsListHelper
  def assign_text_color(hex)
    # Separate the hex out into the 3 sections
    result = hex.match(/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i)
    # convert to rgb
    rgb = {
      r: result[1].to_i(16),
      g: result[2].to_i(16),
      b: result[3].to_i(16)
    }
    # based on rgb, determine text color. Formula comes from here: https://www.w3.org/TR/AERT/#color-contrast
    (rgb[:r] * 299 + rgb[:g] * 587 + rgb[:b] * 114) / 1000 > 125 ? 'black' : 'white'
  end
end

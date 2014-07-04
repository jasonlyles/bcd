class String
  def despace
    self.gsub(' ','')
  end

  def to_snake_case
    self.downcase.gsub(' ','_')
  end
end
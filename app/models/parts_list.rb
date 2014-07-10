class PartsList < ActiveRecord::Base
  belongs_to :product
  mount_uploader :name, PartsListUploader
  process_in_background :name

  attr_accessible :name, :product_id, :parts_list_type, :name_cache, :remove_name

  validates :parts_list_type, :presence => true, :inclusion => {:in => ['HTML','html','XML','xml']}
  validates :product_id, :presence => true
  validates :name, :presence => true

  def filename
    Pathname(self.name.to_s).basename.to_s
  end

  def self.get_list(parts_lists, list_type)
    list = nil
    parts_lists.each do |pl|
      if pl.parts_list_type && (pl.parts_list_type.upcase == list_type.upcase)
        list = pl
        break
      end
    end
    list
  end
end

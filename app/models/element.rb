# frozen_string_literal: true

# An Element is the combination of a part and color. A 2x4 brick is a part, red
# is a color, a red 2x4 brick is an element.
class Element < ApplicationRecord
  belongs_to :part
  belongs_to :color
  has_many :lots, dependent: :restrict_with_error
  has_many :parts_lists, through: :lots
  has_one :image
  mount_uploader :image, ImageUploader

  after_commit :destroy_image, on: :destroy

  # attr_accessible :part_id, :color_id, :image, :image_cache, :remove_image, :original_image_url

  validates :color_id, uniqueness: { scope: :part_id }
  validates :part_id, :color_id, presence: true

  ransacker :has_image,
            formatter: proc { |boolean|
              results = Element.has_image?(boolean).map(&:id)
              results.present? ? results : nil
            }, splat_params: true do |parent|
    parent.table[:id]
  end

  def destroy_image
    dir_to_remove = "#{Rails.root}/public/#{image.store_dir}" # Only needed for local.
    remove_image!
    # Only needed for local. Empty AWS gets deleted automatically using remove_image!
    FileUtils.rm_r(dir_to_remove) if (Rails.env.development? || Rails.env.test?) && Dir.exist?(dir_to_remove)
  end

  def part_name
    part.name
  end

  def color_name
    color.bl_name
  end

  # rubocop:disable Naming/PredicateName
  def self.has_image?(boolean)
    if boolean == 'true'
      where('image IS NOT NULL')
    else
      where('image IS NULL')
    end
  end
  # rubocop:enable Naming/PredicateName

  # TODO: Maybe expand this to update other attributes as well, not just the image.
  # year_from and year_to are also available.
  def update_from_rebrickable(part_id, color_id)
    data = Rebrickable.get_element_combo(part_id: part_id, color_id: color_id)
    return unless data['part_img_url'].present?

    self.original_image_url = data['part_img_url']
    part.check_rebrickable = false
    part.save!
  end

  def update_from_bricklink(part_id, color_id)
    data = Bricklink.get_element_image(part_id: part_id, color_id: color_id)
    return unless data['data'].present? && data['data']['thumbnail_url'].present?

    self.original_image_url = "https:#{data['data']['thumbnail_url']}"
    part.check_bricklink = false
    part.save!
  end

  def generate_guid
    self.guid = SecureRandom.hex(16)
  end

  def part_and_color_name_string
    "#{color.bl_name} #{part.name}"
  end

  def self.get_part_and_color(part_key)
    part_id, color_id = part_key.split('_')

    part = Part.find_by_ldraw_id(part_id)
    part = Part.find_by_bl_id(part_id) if part.blank?

    color = Color.find_by_ldraw_id(color_id)

    raise "Missing Part LDraw ID: #{part_id}" if part.blank?
    raise "Missing Color LDraw ID: #{color_id}" if color.blank?

    [part, color]
  end

  def self.find_or_create_via_external(part_key)
    part, color = get_part_and_color(part_key)
    element = Element.find_or_create_by(part_id: part.id, color_id: color.id)

    unless element.image.present?
      element.update_from_rebrickable(part.ldraw_id, color.ldraw_id)
      element.update_from_bricklink(part.bl_id, color.bl_id) unless element.original_image_url
      element.generate_guid
      element.store_image
      element.save!
    end
    element
  end

  # TODO: Maybe in here: # Try to add alpha channel to images via RMagick: take
  # their white background and make it transparent.
  # TODO: This seems to be incomplete.
  def store_image
    # To make the bucket public read:
    # https://stackoverflow.com/questions/19176926/how-to-make-all-objects-in-aws-s3-bucket-public-by-default/23102551#23102551
    # Be sure to add /* to the end of the resource name for the generated policy
    return unless original_image_url

    root_local_dir = "#{Rails.root}/tmp"
    parts_image_dir = "#{root_local_dir}/parts_images"
    Dir.mkdir(root_local_dir) unless Dir.exist?(root_local_dir)
    Dir.mkdir(parts_image_dir) unless Dir.exist?(parts_image_dir)
    extension = File.extname(original_image_url)
    file = "#{parts_image_dir}/#{guid}#{extension}"
    begin
      File.open(file, 'wb') do |fo|
        fo.write File.open(original_image_url).read
      end
    rescue StandardError => e
      logger.error "There was a problem getting an image for #{original_image_url}: #{e.message}"
    end
    # s3_file = "parts_images/#{color_id}/#{guid}#{extension}"
    self.image = File.open(file)
    save
  end
end

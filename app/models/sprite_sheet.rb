require 'sprite_factory'

class SpriteSheet
  attr_writer :elements, :parts_list

  def initialize(parts_list)
    @parts_list = parts_list
    @elements = parts_list.elements
  end

  def generate
    # I think in order to do the sprite sheet thing, I'll have to copy all images
    # to a single folder in S3, and then call the SpriteFactory thing on that folder.
    # Then I'll have to pick up the generated files and move them out to somewhere
    # else that I want them maybe, or maybe just serve them out of that folder.
    # Maybe create a folder for each parts_list where I store all the medium_
    # images (for better display on retina displays) and then just serve the files
    # from that folder.
    #binding.pry
    # 1. Get all images and put them in a working dir
    # 2. Run spritefactory on them
    # 3. Upload resulting spritesheet file to S3. Will need to create folders in
    # some bucket for each products assets
    # 4. Take storage location of image file and use that to alter image references in css file.
    # 5. Upload css file and get location of uploaded file and tell parts_list where its
    # image and css files are stored.

    # Set up the working dir
    working_dir_base = "#{Rails.root}/public/temp_working_parts_lists"
    Dir.mkdir(working_dir_base) unless Dir.exists?(working_dir_base)

    working_dir = "#{working_dir_base}/#{@parts_list.id}"
    Dir.mkdir(working_dir) unless Dir.exists?(working_dir)

    # Grab all images and throw them in the working dir
    @elements.each do |element|
      # TODO: May have to do this a bit differently when pulling images from S3:
      medium_image = element.image.url(:thumb)
      file_name = File.basename(medium_image)
      FileUtils.copy("#{Rails.root}/public#{medium_image}", "#{working_dir}/#{file_name}")
    end

    #Generate a sprite from the images
    SpriteFactory.run!(working_dir, layout: :vertical, nocomments: true)

    # Grab the generated files
    generated_file_base = "#{working_dir_base}/#{@parts_list.id}"
    png = "#{generated_file_base}.png"
    css = "#{generated_file_base}.css"

    #TODO: Pick back up here!!!
    # I was able to generate a png for the medium images for the rollback tow truck.
    # I don't think I even have all the images and the generated png is 2.9 MB.
    # That's not too bad, but it's not great either. The big models may have 10
    # times as many images and it won't be any good to have a single 30MB image
    # for them to download. Look into optimizations such as compression, maybe
    # using smaller images, etc.
    # Also, need to maybe put more space in between images so images don't bleed
    # into each other when users are zooming in/out their screen.

    # Before I can do the next part, I need to add an uploader for css files,
    # (and maybe one for the spreadsheet_png column?) and columns in the parts
    # list for the png url and the css url

    # Upload the sprite png and get back where it is stored

    # Alter the CSS file to point to the newly uploaded sprite png
    binding.pry
  end
end

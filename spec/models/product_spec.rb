require 'spec_helper'

describe Product do
  before do
    @product_type = FactoryBot.create(:product_type, digital_product: true)
    @product_type2 = FactoryBot.create(:product_type, name: 'Models', digital_product: false)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory)
  end

  it 'should find live products from the same category' do
    category = FactoryBot.create(:category, name: 'blah')
    products = [FactoryBot.create(:product),
                FactoryBot.create(:product,
                                  name: 'Grader',
                                  product_code: 'CV002',
                                  description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.',
                                  price: '5.00',
                                  ready_for_public: 'f'),
                FactoryBot.create(:product,
                                  name: 'Zeppelin',
                                  product_code: 'CV003',
                                  description: 'Winter Village Zeppelin... are you kidding? w00t! Flatten London with this Winter Village Zeppelin, then land in a nearby village and celebrate Christmas.',
                                  price: '5.00',
                                  ready_for_public: 't'),
                FactoryBot.create(:product,
                                  name: 'Chocolate Factory',
                                  product_code: 'CB004',
                                  description: "Winter Village Chocolate Factory... are you kidding? w00t! Charlie won't believe his eyes when he gets to celebrate Christmas inside a chocolate factory... with oompah-loompahs.",
                                  price: '5.00',
                                  ready_for_public: 't',
                                  category_id: category.id)]
    @product = products[1]
    products = @product.find_live_products_from_same_category
    expect(products.size).to eq(2)
  end

  it 'should only find models that are ready for the public' do
    # First product is ready for public, 2nd one is not, so there should only be 1 product
    products = [FactoryBot.create(:product),
                FactoryBot.create(:product,
                                  name: 'Grader',
                                  product_code: 'WC002',
                                  description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.',
                                  price: '5.00',
                                  ready_for_public: 'f')]
    @products = Product.find_products_for_sale
    expect(@products.size).to eq(1)
  end

  it 'should delete related images' do
    @product = FactoryBot.create(:product)
    @image = FactoryBot.create(:image)

    expect { @product.destroy }.to change(Image, :count)
  end

  it 'is valid with valid attributes' do
    @product = FactoryBot.create(:product)
    expect(@product).to be_valid
  end

  it 'is invalid if product_code is not unique' do
    @products = [FactoryBot.create(:product),
                 FactoryBot.create(:product,
                                   name: 'Grader',
                                   product_code: 'WC002',
                                   product_type_id: @product_type.id,
                                   description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.',
                                   price: '5.00',
                                   ready_for_public: 't')]
    product = Product.create(price: 5,
                             product_code: 'WC002',
                             product_type_id: @product_type.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'blah blah blah',
                             tweet: 'Hello tweeters.',
                             ready_for_public: true,
                             description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.')
    expect(product.errors[:product_code]).to eq(['has already been taken'])
  end

  it 'is invalid if name is not unique' do
    @products = [FactoryBot.create(:product),
                 FactoryBot.create(:product,
                                   name: 'Grader',
                                   product_code: 'WC002',
                                   product_type_id: @product_type.id,
                                   description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.',
                                   price: '5.00',
                                   ready_for_public: 't')]
    product = Product.create(price: 5,
                             product_code: 'XX001',
                             product_type_id: @product_type.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'Grader',
                             tweet: 'Hello tweeters.',
                             ready_for_public: true,
                             description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.')
    expect(product.errors[:name]).to eq(['has already been taken'])
  end

  it "is invalid with a description that's too short" do
    product = Product.create(price: 5,
                             product_code: 'XX001',
                             product_type_id: @product_type.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'blah blah blah',
                             tweet: 'Hello tweeters.',
                             ready_for_public: true,
                             description: "It's pretty awesome.")
    expect(product.errors[:description]).to eq(['is too short (minimum is 100 characters)'])
  end

  it "is invalid with a tweet that's too long" do
    product = Product.create(price: 5,
                             product_code: 'XX001',
                             product_type_id: @product_type.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'blah blah blah',
                             tweet: 'Hello tweeters, blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah.',
                             ready_for_public: true,
                             description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.')
    expect(product.errors[:tweet]).to eq(['is too long (maximum is 97 characters)'])
  end

  it 'is invalid if price is not a number' do
    product = Product.create(price: 'ralph',
                             product_code: 'XX001',
                             product_type_id: @product_type.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'blah blah blah',
                             tweet: 'Hello tweeters.',
                             ready_for_public: true,
                             description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.')
    expect(product.errors[:price]).to include(" Hey... Don't you want to make some money on this?")
  end

  it 'should be invalid if it is free and has a price > 0' do
    @product = FactoryBot.build(:free_product, price: 10)
    @product.valid?

    expect(@product.errors[:price]).to include(' Freebies should be $0')
  end

  it 'should be valid if it is free and has a price of 0' do
    @product = FactoryBot.create(:free_product)

    expect(@product).to be_valid
  end

  it "should be invalid if it has a product_code that doesn't match the pattern for Instructions" do
    @product = FactoryBot.build(:product, product_code: 'doh')
    @product.valid?

    expect(@product.errors[:product_code]).to include('Instruction product codes must follow the pattern CB002.')
  end

  it "should be invalid if it has a product_code that doesn't match the pattern for Models" do
    @product1 = FactoryBot.create(:product)
    @product = FactoryBot.build(:product, product_type_id: @product_type2.id, name: 'fake model', product_code: 'doh')
    @product.valid?

    expect(@product.errors[:product_code]).to include('Model product codes must follow the pattern CB002M.')
  end

  it "should be invalid if it has a product_code that doesn't match the pattern for Kits" do
    @product_type3 = FactoryBot.create(:product_type, name: 'Kits', digital_product: false)
    @product1 = FactoryBot.create(:product)
    @product = FactoryBot.build(:product, product_type_id: @product_type3.id, name: 'fake kit', product_code: 'doh')
    @product.valid?

    expect(@product.errors[:product_code]).to include('Kit product codes must follow the pattern CB002K.')
  end

  it 'should be invalid if there is no base model with the same base product_code for Models' do
    @product1 = FactoryBot.create(:product)
    @product = FactoryBot.build(:product, product_type_id: @product_type2.id, name: 'fake model', product_code: 'HH001M')
    @product.valid?

    expect(@product.errors[:product_code]).to include('Model product codes must have a base model with a product code of HH001')
  end

  it 'should be invalid if there is no base model with the same base product_code for Kits' do
    @product_type3 = FactoryBot.create(:product_type, name: 'Kits')
    @product1 = FactoryBot.create(:product)
    @product = FactoryBot.build(:product, product_type_id: @product_type3.id, name: 'fake kit', product_code: 'HH001K')
    @product.valid?

    expect(@product.errors[:product_code]).to include('Kit product codes must have a base model with a product code of HH001')
  end

  describe 'destroy' do
    it 'should switch the ready_for_public flag to false if there are existing orders for the product' do
      @product = FactoryBot.create(:product)
      @order = FactoryBot.create(:order)
      @line_item = FactoryBot.create(:line_item, product_id: @product.id, order_id: @order.id)

      expect { @product.destroy }.to change(@product, :ready_for_public).from(true).to(false)
    end

    it 'should not destroy the product if there are existing orders for the product' do
      @product = FactoryBot.create(:product)
      @order = FactoryBot.create(:order)
      @line_item = FactoryBot.create(:line_item, product_id: @product.id, order_id: @order.id)

      expect { @product.destroy }.to_not change(Product, :count)
    end

    it 'should delete the product if there are no orders for the product' do
      @product = FactoryBot.create(:product)

      expect { @product.destroy }.to change(Product, :count)
    end
  end

  it 'should not let the radmin make a product live if the pdf has not been uploaded' do
    @product = Product.create(price: 5,
                              product_code: 'XX001',
                              product_type_id: @product_type.id,
                              subcategory_id: 1,
                              category_id: 1,
                              name: 'blah blah blah',
                              tweet: 'Hello tweeters.',
                              ready_for_public: true,
                              description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.',
                              pdf: nil)

    expect(@product.errors[:ready_for_public]).to eq([": Can't allow you to make a product live before you upload the PDF."])
  end

  describe 'decrement_quantity' do
    it 'should decrement the quantity of a physical product' do
      @product = Product.new(price: '5',
                             product_code: 'XX001',
                             product_type_id: @product_type2.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'blah blah blah',
                             tweet: 'Hello tweeters.',
                             ready_for_public: true,
                             quantity: '5',
                             description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.')
      expect { @product.decrement_quantity(2) }.to change(@product, :quantity).from(5).to(3)
    end

    it 'should not decrement the quantity of a digital product' do
      @product = Product.new(price: '5',
                             product_code: 'XX001',
                             product_type_id: @product_type.id,
                             subcategory_id: 1,
                             category_id: 1,
                             name: 'blah blah blah',
                             tweet: 'Hello tweeters.',
                             ready_for_public: true,
                             quantity: '1',
                             description: 'asdf asd asd fsdf asdfas asfjh alsdjf lasfj lasjd flkasjdflajs flasjdflasdlk jlksadj flasj flkasjd flaskdjf las djflkas fjlksa jlksadjf.')
      expect { @product.decrement_quantity(2) }.to_not change(@product, :quantity)
    end
  end

  describe 'out_of_stock?' do
    it 'should return false if quantity > 0' do
      @base_product = FactoryBot.create(:product, quantity: 1, product_type_id: @product_type.id, product_code: 'XX111')
      @product = FactoryBot.create(:product, quantity: 2, product_type_id: @product_type2.id, product_code: 'XX111M', name: 'fake product')
      expect(@product.out_of_stock?).to eq(false)
    end

    it 'should return true if quantity is 0' do
      @product_type3 = FactoryBot.create(:product_type, name: 'Kits', digital_product: false)
      @base_product = FactoryBot.create(:product, quantity: 1, product_type_id: @product_type.id, product_code: 'XX111')
      @product = FactoryBot.create(:product, quantity: 0, product_type_id: @product_type3.id, product_code: 'XX111K', name: 'fake product')
      expect(@product.out_of_stock?).to eq(true)
    end
  end

  describe 'base_product_code' do
    it 'should pick out the base product code when passed a product code' do
      @base_product = FactoryBot.create(:product, product_type_id: @product_type.id, product_code: 'XX001')
      @product = FactoryBot.create(:product, product_type_id: @product_type2.id, product_code: 'XX001M', name: 'fake product')
      expect(@product.base_product_code('XX045C')).to eq('XX045')
    end

    it 'should pick out the base product code using the records product_code' do
      @base_product = FactoryBot.create(:product, product_type_id: @product_type.id, product_code: 'XX001')
      @product = FactoryBot.create(:product, product_type_id: @product_type2.id, product_code: 'XX001M', name: 'fake product')
      expect(@product.base_product_code).to eq('XX001')
    end
  end

  describe 'find_by_base_product_code' do
    it 'should by a product by its base code' do
      @product = FactoryBot.create(:product, product_type_id: @product_type.id, product_code: 'XX001')
      expect(Product.find_by_base_product_code('XX001M').product_code).to eq('XX001')
    end
  end

  describe 'find all by price' do
    it 'should find all products at a given price point' do
      @product1 = FactoryBot.create(:product)
      @product2 = FactoryBot.create(:product, product_type_id: @product_type.id, name: 'super fakey', product_code: 'HH001', price: 10)
      @product3 = FactoryBot.create(:product, product_type_id: @product_type.id, name: 'free fakey', product_code: 'HH002', free: 't', price: 0)

      prods = Product.find_all_by_price(10)
      expect(prods.length).to eq(2)
      freebies = Product.find_all_by_price('free')
      expect(freebies.length).to eq(1)
    end
  end

  describe 'physical_product?' do
    it 'should return true if product type is not blank and is != Instructions' do
      @product1 = FactoryBot.create(:product)
      @product2 = FactoryBot.create(:physical_product)

      expect(@product2.physical_product?).to eq(true)
    end

    it 'should return false if product type is Instructions or product type is blank' do
      @product1 = FactoryBot.create(:product)

      expect(@product1.physical_product?).to eq(false)

      # This represents the case where a product is brand new (via the new action) and doesn't have a type yet
      @product2 = FactoryBot.build(:product, product_type_id: '', product_code: 'VV001', name: 'Fake')

      expect(@product2.physical_product?).to eq(false)
    end
  end

  describe 'digital_product?' do
    it 'should return true if product type is not blank and is == Instructions' do
      @product1 = FactoryBot.create(:product)
      @product2 = FactoryBot.create(:physical_product)

      expect(@product1.digital_product?).to eq(true)
    end

    it 'should return false if product type is not Instructions or product type is blank' do
      @product1 = FactoryBot.create(:product)
      @product2 = FactoryBot.create(:physical_product, product_type_id: @product_type2.id)

      expect(@product2.digital_product?).to eq(false)

      # This represents the case where a product is brand new (via the new action) and doesn't have a type yet.
      # It gets set to true so that all fields are displayed on the product form
      @product3 = FactoryBot.build(:product, product_type_id: '', product_code: 'VV001', name: 'Fake')

      expect(@product3.digital_product?).to eq(true)
    end
  end

  describe 'main_image' do
    it 'should return nil if no image can be found for the product' do
      @product = FactoryBot.create(:product)

      expect(@product.main_image).to be_nil
    end

    it 'should return an image url if an image is found for the product' do
      @product = FactoryBot.create(:product)
      @image = FactoryBot.create(:image)

      expect(@product.main_image).not_to be_nil
    end
  end

  describe 'retire' do
    it 'should set category_id and subcategory_id to Retired IDs and ready_for_public to false' do
      @retired_category = FactoryBot.create(:category, name: 'Retired')
      @retired_subcategory = FactoryBot.create(:subcategory, name: 'Retired', code: 'BB')
      @product = FactoryBot.create(:product, ready_for_public: true)
      @product.retire

      expect(@product.category_id).to eq(@retired_category.id)
      expect(@product.subcategory_id).to eq(@retired_subcategory.id)
      expect(@product.ready_for_public).to eq(false)
    end
  end

  describe 'discounted_price' do
    it 'should return the price if there is no discount' do
      @product = FactoryBot.create(:product, discount_percentage: 0)

      expect(@product.discounted_price.to_f).to eq(@product.price.to_f)
    end

    it 'should return a discounted price if discount_percentage is set' do
      @product = FactoryBot.create(:product, discount_percentage: 25)

      expect(@product.discounted_price.to_f).to eq(7.5)
    end
  end

  describe 'assemble_changes_since_last_etsy_update' do
    context 'with no changes since the last update to etsy' do
      it 'should return an empty array' do
        product = FactoryBot.create(:product)
        sleep 1
        product.update(etsy_updated_at: Time.now)

        expect(product.assemble_changes_since_last_etsy_update.map(&:first).sort).to eq([])
      end
    end

    context 'with no update to etsy' do
      it 'should return a nil' do
        product = FactoryBot.create(:product)

        expect(product.assemble_changes_since_last_etsy_update).to be_nil
      end
    end

    context 'with changes to everything' do
      it 'should get all changes since the last update to etsy' do
        product = FactoryBot.create(:product)
        FactoryBot.create(:image, product:, position: 1)
        sleep 1
        # update name and price so they will show up as changed
        product.update(name: 'Updated name', price: 4.35, etsy_updated_at: Time.now)
        # add some tags so tags will show up as changed
        product.tag_list.add('tag1', 'tag2')
        product.save
        # Add an image so that will show up as changed
        image2 = FactoryBot.create(:image, product:)
        # Re-position image2 so re-ordered images will show up as changed
        image2.update(position: 1)

        expect(product.assemble_changes_since_last_etsy_update.map(&:first).sort).to eq(['image added', 'images re-ordered', 'name changed', 'price changed', 'tags changed'])
      end
    end

    context 'with only images added' do
      it 'should show images added, but not reordered' do
        product = FactoryBot.create(:product)
        sleep 1
        product.update(etsy_updated_at: Time.now)
        # Add an image so that will show up as changed
        image = FactoryBot.create(:image, product:)

        expect(product.assemble_changes_since_last_etsy_update.map(&:first).sort).to eq(['image added'])
      end
    end
  end
end

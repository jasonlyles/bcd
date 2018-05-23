task add_designer: :environment do
  puts 'Adding designer'
  products = Product.all
  products.each do |product|
    if %w[TE003 CB002 CB007 CB013 CB014 CB016 CB022 CB024 CB026 CB027 CB028 CB030 CV001 CV007 CV009 CV013].include?(product.product_code)
      product.designer = 'jason_lyles'
    else
      product.designer = 'brian_lyles'
    end
    product.save
  end
end

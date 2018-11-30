# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Add product types
instructions = ProductType.create!(name: 'Instructions', digital_product: true, ready_for_public: true, comes_with_title: 'What do I get when I buy instructions?', description: 'Instructions include a PDF with clear steps on how to build the models. They also include an HTML parts list you can open in your internet browser. This parts list includes a checklist you can use to determine how many of each piece you already have. Submit your checklist, and customized XML is generated that you can use to upload to your Bricklink Wanted List to acquire the pieces you still need. Check out our FAQ and BCD Tutorial if you have any questions.', comes_with_description: 'You get a PDF with complete picture instructions using easy to follow steps. You also get 2 parts lists you can use to collect the pieces necessary to complete our models. We give complete instructions on how to use the parts lists on our new user tutorial page here: www.brickcitydepot.com/new_user_tutorial')
models = ProductType.create!(name: 'Models', digital_product: false, ready_for_public: true, comes_with_title: 'What do I get when I buy a model?', description: "Models are based off of our existing products and might not conform to our instructions. Building interiors, bricks used, parts counts and colors may vary from what you see in the instructions for the model. Models come with downloadable instructions for the related item, although the instructions may not match up with the model you are getting. Instructions will always show you how to build the 'official' model. We only use new parts for our models, unless new ones aren't available. If you're interested in the building experience, check out our kits.", comes_with_description: 'You may or may not get a PDF with complete picture instructions and parts lists depending on if the model is one you can also buy instructions for. If you can buy the instructions separately, then they will be included with this model. Kits will include all necessary pieces to build the model. Pre-built models may or may not conform exactly to the instructions you get for the model.')
kits = ProductType.create!(name: 'Kits', digital_product: false, ready_for_public: true, comes_with_title: 'What do I get when I buy a kit?', description: "Kits include complete downloadable instructions and parts lists along with all the pieces needed to build the model. After your purchase is completed, you will be able to download instructions and we will ship the pieces for the model to you via the address you have registered with Paypal. If you just want to expand your city and don't have time to build a kit, check out our models.", comes_with_description: 'You get a PDF with complete picture instructions using easy to follow steps. You also get 2 parts lists you can use to collect the pieces necessary to build the model. Kits will also include all necessary pieces to build the model. Pre-built models may or may not conform to the instructions you get for the model.')
crafts = ProductType.create!(name: 'Crafts', digital_product: false, ready_for_public: false, comes_with_title: '', description: '', comes_with_description: '')

# Add categories
city_category = Category.create!(name: 'City', description: "Build your city or town up with these great models that will fit right in with your existing setup. Modular buildings in the Cafe Corner style, smaller playset-type buildings, cars and trucks to get your Lego people where they're going. Bring your city to life.", ready_for_public: true)
train_category = Category.create!(name: 'Train', description: 'Expand your layout with these awesome rail models. Buildings, engines, rolling stock, passenger cars, maintenance of way vehicles, past, present, everything you need to make your layout first class.', ready_for_public: true)
military_category = Category.create!(name: 'Military', description: "Have fun building military vehicles and buildings from the past and present. Re-live some of history's great battles with these excellent models.", ready_for_public: true)
winter_village_category = Category.create!(name: 'Winter Village', ready_for_public: true, description: 'Expand your Winter Village with these great models from Brick City Depot. All models have open backs for a playset feel.')
# castle_category = Category.create!(:name => "Castle", :ready_for_public => true, :description => "Bring your castle layout to life with these great add-ons. Whether you are building peasant villages, or pitched battles for control of a castle, Brick City Depot has you covered.")
retired_category = Category.create!(name: 'Retired', ready_for_public: false, description: 'This category is for retired models. A retired model is one that has at least 1 order. Otherwise we could just delete the product. This will let us be able to see historical numbers, even for products no longer available to the public.')
other_category = Category.create!(name: 'Other', ready_for_public: true, description: "Everything that doesn't quite fit into the other categories; castle, fantasy, technic, mini, micro, etc.")
alternative_category = Category.create!(name: 'Alternative Builds', ready_for_public: false, description: 'These models use pieces mostly from a single official Lego set, making pieces much easier to acquire. All you have to do is buy the specified Lego set, and perhaps a few additional pieces to complete the set.')

# Add Subcategories
city_vehicles = Subcategory.create!(name: 'Vehicles', category_id: city_category.id, code: 'CV', ready_for_public: true)
city_buildings = Subcategory.create!(name: 'Modular Buildings', category_id: city_category.id, code: 'CB', ready_for_public: true)
train_buildings = Subcategory.create!(name: 'Buildings', category_id: train_category.id, code: 'TB', ready_for_public: true)
train_engines = Subcategory.create!(name: 'Engines and Rolling Stock', category_id: train_category.id, code: 'TE', ready_for_public: true)
world_war2 = Subcategory.create!(name: 'World War II', category_id: military_category.id, code: 'WW', ready_for_public: true)
modern_warfare = Subcategory.create!(name: 'Modern Warfare', category_id: military_category.id, code: 'MW', ready_for_public: true)
castle = Subcategory.create!(name: 'Castle', category_id: other_category.id, code: 'CA', ready_for_public: true)
mini_micro = Subcategory.create!(name: 'Mini & Micro', category_id: other_category.id, code: 'MM', ready_for_public: true)
winter_village_buildings = Subcategory.create!(name: 'Buildings', category_id: winter_village_category.id, code: 'WV', ready_for_public: true)
retired_subcategory = Subcategory.create!(name: 'Retired', category_id: retired_category.id, code: 'RT', ready_for_public: false)

# Add Products
# City Vehicles
cv001 = Product.create!(product_type_id: instructions.id, name: 'Rollback Tow Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV001', description: 'The model that started it all. The original, the classic, the rollback tow truck. This model features a tilting and sliding bed, tool storage, and an array of levers. Vehicles that are 4 studs wide can fit on the bed with no problems. 6 stud wide cars can fit too if the bed rail system is changed.', price: 3, ready_for_public: false, tweet: 'With tilting/sliding bed and tool storage, this tow truck will fit perfectly in your Lego town.')
cv002 = Product.create!(product_type_id: instructions.id, name: 'Glass Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV002', price: 3, ready_for_public: false, tweet: 'This glass delivery truck will get the panes to the job on time.', description: 'Glass is going to break in your city, and who will be around to replace it when it does? Your friendly local glass replacement technicians! Get them there in this truck specially equipped to carry glass safely to the job site.')
cv003 = Product.create!(product_type_id: instructions.id, name: 'Sewer Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV003', price: 3, ready_for_public: false, tweet: "Clean up your city's sewers with this truck equipped for the job", description: "It's a messy job, but someone has to do it. Keep the sewers clean and functioning properly in your city for the public's health and safety. Watch for alligators! Truck has a hose that can reach from the back of the truck to a manhole.")
cv004 = Product.create!(product_type_id: instructions.id, name: 'Hi Rail Pickup', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV004', price: 3, ready_for_public: false, tweet: 'Make sure the rails are clear and safe with this rail maintenance pickup', description: "You can't just trust that the rails in your layout will be clear and free of damage. You need someone to go inspect before the passenger trains come through. This maintenance of way pickup is perfect for riding the rails ahead of the trains and ensuring the safety of the trains to come. Instructions include steps to build both single and double plows.")
cv005 = Product.create!(product_type_id: instructions.id, name: 'NYPD Emergency Support Vehicle', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV005', price: 3, ready_for_public: false, tweet: 'Launch the raft and get to the foundering ship quickly with this boat-launching truck.', description: "When there's a boat in trouble, you need first responders to get to the scene quickly. This New York Police Department truck is equipped to launch a raft and get officers to the rescue of distressed boaters quickly. Truck has removable side panels for equipment storage.")
cv006 = Product.create!(product_type_id: instructions.id, name: 'NYPD Radio Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV006', price: 3, ready_for_public: false, tweet: "NYPD's elite emergency services unit's radio truck.", description: "New York Police Departments' elite Emergency Services Unit is a combined rescue/SWAT team that are called on when situations get out of hand. This is their radio truck.")
cv007 = Product.create!(product_type_id: instructions.id, name: 'Hi Rail Dump Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV007', price: 3, ready_for_public: false, tweet: 'Time for rail repair! Get the job done with this Hi Rail Dump Truck.', description: "When it's time to repair your rails, send in the heavy equipment to get the job done. This maintenance of way dump truck can haul rocks to repair a washed-out rail bed. Dumper bed tilts and the rear door opens to dump the load. Instructions come with steps for building single and double plows.")
cv008 = Product.create!(product_type_id: instructions.id, name: 'Fire Brush Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV008', price: 3, ready_for_public: false, tweet: 'Get deep into the woods to fight fires with this rough and ready brush truck.', description: 'Your rural fire crew needs a truck like this one to get back into the woods and get to where the action is when the forest fires are raging out of control. Heavy-duty brush guard protects the front end of the truck when getting into deep underbrush. Lift up the rear tailgate to get access to hose storage and the trucks controls.')
cv009 = Product.create!(product_type_id: instructions.id, name: 'Work Truck', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV009', price: 3, ready_for_public: false, tweet: 'This generic work truck features some great SNOT techniques.', description: 'This generic work truck can serve many purposes in your city. Truck can be used as an electricians truck, plumbers truck, cable installers truck, etc. Customize it by adding stickers for your favorite company, or adding ladders on top. The truck cab is 6 studs wide, and the body is 7 studs wide. The truck body incorporates 7 cabinets for tool/hardware storage, and makes heavy use of SNOT techniques to fit so much storage in such a small space.')
cv010 = Product.create!(product_type_id: instructions.id, name: 'American Ambulance', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV010', price: 3, ready_for_public: false, tweet: 'Get to the scene of the accident quickly with this Lego ambulance.', description: "Help keep your city's residents safe and make sure they have quick transport to the hospital should there be an accident. This ambulance features a removable roof and opening rear doors for accessing the rear. The patient area has an IV tower, lifesaving station, and a place to keep a stretcher secure. Ambulance also features a detailed undercarriage.")
cv011 = Product.create!(product_type_id: instructions.id, name: 'Hot Rod', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV011', description: "Let your minifigs cruise the streets in style with this model patterned after a '32 Ford Hot Rod.  These instructions include variations for both coupe and convertible. This model can be built in either red or black.", price: 2.5, tweet: "Cruise the Lego streets in style with this sweet '32 Ford Hot Rod", ready_for_public: false)
cv012 = Product.create!(product_type_id: instructions.id, name: 'Vintage Police Car', category_id: city_category.id, subcategory_id: city_vehicles.id, product_code: 'CV012', price: 2, ready_for_public: false, tweet: 'Patrol the streets and keep your city safe with this vintage cruiser.', description: 'Keep your citizens safe by patrolling the mean streets in this vintage cruiser. This model is patterned after older style black and whites. Model features a simple build, classic vehicle sizing and a spotlight on the drivers side.')

# City Buildings
cb001 = Product.create!(product_type_id: instructions.id, name: 'Police Precinct', category_id: city_category.id, subcategory_id: city_buildings.id, product_code: 'CB001', price: 10, ready_for_public: false, tweet: 'This police precinct will fit in with your existing modular buildings.', description: "Your modular city police need a downtown headquarters in order to keep tabs on the criminal element that prey on innocent civilians. This building is modular and features a furnished interior. First floor has a receiving desk, weapons rack and desks for detectives. Second floor has a lineup room, interrogation room and a holding cell. Instructions include directions for building the CV012 Vintage Police Car. There are also directions for building a bat-signal to go on the roof, if that's your sort of thing. Building sits on a 32x32 baseplate.")
cb002 = Product.create!(product_type_id: instructions.id, name: 'Colonial Revival House', category_id: city_category.id, subcategory_id: city_buildings.id, product_code: 'CB002', description: 'One of our best sellers, the Colonial Revival house modeled after a real house in the Fan in Richmond, VA. This model is modular and features 2 furnished floors, a crawlspace and a porch on front and back. This model will go great in any row house neighborhood in your modular city. Building sits on a 16x32 baseplate.', price: 10, ready_for_public: false, tweet: 'Classic row house architecture to jump-start your modular neighborhood.')
cb003 = Product.create!(product_type_id: instructions.id, name: 'Stone-Faced Restaurant', category_id: city_category.id, subcategory_id: city_buildings.id, product_code: 'CB003', price: 10, ready_for_public: false, tweet: 'Customize this restaurant for your modular city.', description: "Your modular city citizens want to have somewhere nice to eat out when they feel like a night out on the town. You can choose what type of restaurant you'd like to add to your city using 1 of the 4 logos we give you directions to build. Choose from a cheeseburger, noodle bowl, soup bowl or martini glass logo, or create your own logo! Model features a modular build, and a detailed interior with a spacious dining area and a full kitchen. Building sits on a 32x32 baseplate.")
cb004 = Product.create!(product_type_id: instructions.id, name: 'Vintage Service Station', category_id: city_category.id, subcategory_id: city_buildings.id, product_code: 'CB004', price: 7.5, ready_for_public: false, tweet: 'Bring your car to this classic service station where the customer is still # 1.', description: "A classic service station to service your classic cars. Customer service isn't a thing of the past at this station modeled after vintage Texaco service stations. This model features a vintage Coke machine, a single bay for working on cars, old-style pumps, and a convertible based on cars from the 1950s. Building sits on a 16x32 baseplate.")
cb005 = Product.create!(product_type_id: instructions.id, name: 'Upper West Side Brownstone House', category_id: city_category.id, subcategory_id: city_buildings.id, product_code: 'CB005', price: 12, ready_for_public: false, tweet: 'Check out this classic New York City architecture.', description: "This classic Brownstone features 3 fully furnished floors, a complete fire escape, stairs between floors, details in and out, and great looks. Your modular city citizens will be proud to live in this high-end residence and show to everyone that they've 'made it'. Building sits on a custom-sized baseplate area of 24x32 studs.")

# Winter Village
wv001 = Product.create!(product_type_id: instructions.id, name: 'Winter Village Train Station', category_id: winter_village_category.id, subcategory_id: winter_village_buildings.id, product_code: 'WV001', price: 5, ready_for_public: false, tweet: 'Add to your winter village and train layouts at the same time', description: 'This little train station is just the right size to go along with the winter village series. You can use this model to expand both your winter village layout and your train layout. These instructions also include directions to make some rail accessories, such as an old-time mailcatcher.')
wv002 = Product.create!(product_type_id: instructions.id, name: 'Winter Village Victorian House', category_id: winter_village_category.id, subcategory_id: winter_village_buildings.id, product_code: 'WV002', price: 5, ready_for_public: false, tweet: "This model will bring back memories of Christmas trips to Grandma's house.", description: "The second in Brick City Depot's winter village series, this house was designed to evoke memories of Christmas trips to Grandma's house. The house is built in a Victorian style, and has an open back consistent with the winter village series.")
wv003 = Product.create!(product_type_id: instructions.id, name: 'Winter Village Gas Station', category_id: winter_village_category.id, subcategory_id: winter_village_buildings.id, product_code: 'WV003', price: 5, ready_for_public: false, tweet: 'This little gas station has a tow truck for rescuing stranded holiday travelers.', description: "The third model in Brick City Depot's winter village series, this little gas station is just the thing to complement your existing winter village. The gas station features a nice little technique for adding 'snow' to any roof, a vintage-styled pump and directions to build a tow truck. Remove the holiday dressing and the snow, and this small gas station would fit in with any small town layout.")
wv004 = Product.create!(product_type_id: instructions.id, name: 'Winter Village Fire Station', category_id: winter_village_category.id, subcategory_id: winter_village_buildings.id, product_code: 'WV004', price: 10, ready_for_public: false, tweet: 'Keep your winter village citizens safe with this great fire station.', description: "This winter village fire station features a removable roof, open back consistent with the winter village series, bunk room for your firefighters, and a nice technique for adding 'snow' to any roof. Also includes directions for building a vintage-styled open cab fire truck. This building has a nice playset feel to it.")

# Train Engines/Rolling Stock
te001 = Product.create!(product_type_id: instructions.id, name: 'Norfolk Southern Passenger Cars', category_id: train_category.id, subcategory_id: train_engines.id, product_code: 'TE001', price: 7.5, ready_for_public: false, tweet: 'Classic coach styling from the golden age of railroading.', description: 'These passenger coaches are modeled after vintage Norfolk Southern cars. Instructions include directions to build four different cars; business car, passenger car, dining car and observation car. All four have removable roofs for easy access to the interior.')
te002 = Product.create!(product_type_id: instructions.id, name: 'Black Boxcar', category_id: train_category.id, subcategory_id: train_engines.id, product_code: 'TE002', price: 3, ready_for_public: false, tweet: 'Add to your cargo train with this generic boxcar.', description: 'Build this boxcar in several different colors and fill out your railyard. An easy build that lends itself to repeating several times in order to build up your train collection. Model features sliding doors on both sides.')

# Train Buildings
tb001 = Product.create!(product_type_id: instructions.id, name: 'Signal Box', category_id: train_category.id, subcategory_id: train_buildings.id, product_code: 'TB001', price: 5, ready_for_public: false, tweet: 'Classic rail architecture built in a modular style', description: 'This signal box is built in a modular style, with separate first floor, second floor and roof sections. This model features nice little details such as a power meter box, a control board on the second floor and tool storage on the first floor. The second story has windows all around so your crew will have a 360 degree view of the railyard. Building sits on a 16x32 baseplate.')
tb002 = Product.create!(product_type_id: instructions.id, name: 'Small Town Train Station', category_id: train_category.id, subcategory_id: train_buildings.id, product_code: 'TB002', price: 10, ready_for_public: false, tweet: '', description: 'This small train station evokes classic small town train stations. With just a few parking spots, a single ticket booth and a small platform, this station is just the right size for a stop in your small town. Directions are given on how to place the track to accommodate 6,7 and 8-stud wide trains. Building and parking lot sit on a custom-sized 32x56 baseplate area.')

# Military
ww001 = Product.create!(product_type_id: instructions.id, name: 'Higgins Boat LCVP', category_id: military_category.id, subcategory_id: world_war2.id, product_code: 'WW001', price: 5, ready_for_public: false, tweet: 'Storm the beaches with this historical landing craft.', description: "The Higgins Boat, or LCVP, is an iconic piece of World War II hardware. More than 20,000 were built with the express purpose of landing soldiers on foreign soil to establish a beachhead for an invasion. This craft most famously served this purpose on June 6th, 1944 when the Allies launched the largest invasion the world had ever seen to try and penetrate Hitler's Atlantic wall. Read more about this historic watercraft at http://en.wikipedia.org/wiki/LCVP")
ww002 = Product.create!(product_type_id: instructions.id, name: 'Bombed Out French Building', category_id: military_category.id, subcategory_id: world_war2.id, product_code: 'WW002', price: 5, ready_for_public: false, tweet: 'This shattered building speaks to the destruction of war.', description: 'This building features a lot of techniques meant to make a building look damaged. Details include lots of little bits of damage, including hanging sections of floor and roof, and portions of the building strewn about. The second story has a perfect place for a machine gun nest to overlook the intersection below.')

# Castle
ca001 = Product.create!(product_type_id: instructions.id, name: 'Medieval Farm House', category_id: other_category.id, subcategory_id: castle.id, product_code: 'CA001', price: 5, ready_for_public: false, tweet: 'Build up your peasant village with this detailed farm house.', description: "It wasn't all castles and battering rams back in the middle ages. Members of the merchant class needed somewhere to live, and this house is the perfect place for the merchant who wants to also keep a small farm. Building and farmyard are situated on a 32x32 baseplate. This is a modular build that features a garden, animal pen, vegetable cart, furniture and a chimney with a fireplace with a hanging pot.")

# Add Images for Products
# Once I get this all set up, I probably want to comment out the section for uploading images so I don't do it every time I re-seed, which is a lot, cause I suck. Will uncomment when it comes time to go live.
product_image_root = '/public/images/product_images'
# City Vehicles
# #CV001 Tow Truck
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv001_small.png")), :product_id => cv001.id, :category_id => city_category.id)
# CV002 Glass Truck
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv002_small.png")), :product_id => cv002.id, :category_id => city_category.id)
# CV003 Sewer Truck
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv003_small.png")), :product_id => cv003.id, :category_id => city_category.id)
# CV004 HiRail Pickup
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv004_small.png")), :product_id => cv004.id, :category_id => city_category.id)
# CV005 NYPD ESU
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv005_small.png")), :product_id => cv005.id, :category_id => city_category.id)
# CV006 NYPD Radio Truck
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv006_small.png")), :product_id => cv006.id, :category_id => city_category.id)
# CV007 HiRail Dumper
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv007_small.png")), :product_id => cv007.id, :category_id => city_category.id)
# CV008 Fire Brush Truck
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv008_small.png")), :product_id => cv008.id, :category_id => city_category.id)
# CV009 Work Truck
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv009_small.png")), :product_id => cv009.id, :category_id => city_category.id)
# CV010 Seattle Ambulance
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv010_small.png")), :product_id => cv010.id, :category_id => city_category.id)
# CV011 Hot Rod
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv011_small.png")), :product_id => cv011.id, :category_id => city_category.id)
# CV012 Vintage Police Car
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cv012_small.png")), :product_id => cv012.id, :category_id => city_category.id)
#
# City Buildings
#
# CB001 Precinct
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cb001_small.png")), :product_id => cb001.id, :category_id => city_category.id)
# CB002 Colonial Revival
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cb002_small.png")), :product_id => cb002.id, :category_id => city_category.id)
# CB003 Stone Face Restaurant
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cb003_small.png")), :product_id => cb003.id, :category_id => city_category.id)
# CB004 Vintage Gas Station
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cb004_small.png")), :product_id => cb004.id, :category_id => city_category.id)
# CB005 NYC Brownstone
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/cb005_small.png")), :product_id => cb005.id, :category_id => city_category.id)
#
# Winter Village
# WV001 Train Station
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/wv001_small.png")), :product_id => wv001.id, :category_id => winter_village_category.id)
# WV002 Grandmas House
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/wv002_small.png")), :product_id => wv002.id, :category_id => winter_village_category.id)
# WV003 Service Station
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/wv003_small.png")), :product_id => wv003.id, :category_id => winter_village_category.id)
# WV004 Fire Station
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/wv004_small.png")), :product_id => wv004.id, :category_id => winter_village_category.id)
#
# Train Engines/Rolling Stock
# TE001 Norfolk Southern Passenger Cars
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/te001_small.png")), :product_id => te001.id, :category_id => train_category.id)
# TE002 Black Boxcar
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/te002_small.png")), :product_id => te002.id, :category_id => train_category.id)
#
# Train Buildings
# TB001 Signal Box
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/tb001_small.png")), :product_id => tb001.id, :category_id => train_category.id)
# TB002 Train Station
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/tb002_small.png")), :product_id => tb002.id, :category_id => train_category.id)
#
# Military
# WW001 Higgins Boat
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/ww001_small.png")), :product_id => ww001.id, :category_id => military_category.id)
# WW002 Blowed-up French Building
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/ww002_small.png")), :product_id => ww002.id, :category_id => military_category.id)
#
# Castle
# CA001 Castle House
# Image.create!(:url => File.open(File.join(Rails.root, "#{product_image_root}/ca001_small.png")), :product_id => ca001.id, :category_id => castle_category.id)
#
# Add Images for Categories
# category_image_root = "/public/images/category_images"
#
# Image.create!(:url => File.open(File.join(Rails.root, "#{category_image_root}/city_banner.jpg")), :category_id => city_category.id)
# Image.create!(:url => File.open(File.join(Rails.root, "#{category_image_root}/train_banner.jpg")), :category_id => train_category.id)
# Image.create!(:url => File.open(File.join(Rails.root, "#{category_image_root}/military_banner.jpg")), :category_id => military_category.id)
# Image.create!(:url => File.open(File.join(Rails.root, "#{category_image_root}/winter_village_banner.jpg")), :category_id => winter_village_category.id)

# Add Admins
Radmin.create!(email: 'lylesjt@gmail.com', password: 'password', password_confirmation: 'password')
Radmin.create!(email: 'lylesbk@yahoo.com', password: 'password', password_confirmation: 'password')

# Add Switches
Switch.create!(switch: 'maintenance_mode')

if Rails.env.development?
  # Add Users
  user1 = User.create!(email: 'lylesjt@yahoo.com', password: 'password', password_confirmation: 'password', tos_accepted: true)
  user2 = User.create!(email: 'crazyjulio@juno.com', password: 'password', password_confirmation: 'password', tos_accepted: true)
  user3 = User.create!(email: 'lylesbk@yahoo.com', password: 'password', password_confirmation: 'password', tos_accepted: true)

  # Add Orders
  Order.create!(user_id: 1, request_id: '09124819284019284901284901281928341902382', transaction_id: '9283492834902893829384209384902384', status: 'COMPLETED')
  Order.create!(user_id: 1, request_id: '49324809238409238409238409238439839839933', transaction_id: '2342342342542323330000230023020302', status: 'COMPLETED')
  Order.create!(user_id: 3, request_id: '12345678900987654321123123123123123123123', transaction_id: '1234321123456763512328137812787277', status: 'COMPLETED')
  Order.create!(user_id: 3, request_id: '12345678900987654321123123123123123123128', transaction_id: '1234321123456763512328137812787278', status: 'INVALID')

  # Add Line Items for Orders
  LineItem.create!(order_id: 1, product_id: cv001.id, quantity: 1, total_price: cv001.price)
  LineItem.create!(order_id: 1, product_id: cb002.id, quantity: 1, total_price: cb002.price)
  LineItem.create!(order_id: 2, product_id: cv011.id, quantity: 1, total_price: cv011.price)
  LineItem.create!(order_id: 3, product_id: cv001.id, quantity: 1, total_price: cv001.price)
  LineItem.create!(order_id: 4, product_id: cv005.id, quantity: 1, total_price: cv005.price)
  LineItem.create!(order_id: 4, product_id: cv011.id, quantity: 1, total_price: cv011.price)
end
# Add some news (Home page defaults to this if tumblr is down)
Update.create!(title: 'This news piece should not be seen on the main page', body: "If this is seen on the main page, it's because of an error! I'm setting up the index page to only show the 3 most recent news items. It may not always stay that way, but that's how I'm setting it up initially. This should only be viewable on the admin news editing side.", image_align: 'float_left', created_at: Date.today - 4)
Update.create!(title: 'Brick City Depot at BrickFair!', body: 'Brick City Depot is going to BrickFair in August! We hope to see you there. Stop by our table and check out our display, and maybe pick up some ready-to-assemble kits. Who knows, we might even give away some free stuff, maybe. Maybe.', image_align: 'top', created_at: Time.now.strftime('%Y-%m-%d %H:%M'))
Update.create!(title: 'Best Sellers', body: "Check out these best sellers. Colonial Revival and Rollback Tow Truck have been consistently our hottest sellers in the City Buildings and Vehicles categories respectively. If you haven't purchased these instructions yet, what are you waiting for? Enjoy!", image_align: 'float_left', created_at: Date.today - 1)
Update.create!(title: 'Announcing the NYC Brownstones', body: "Check it out, fans of New York City architecture and Lego. Just now available is this new line of 3 different styles of brownstone architecture that will fit right in with your city. Don't have a city going yet? Get started now, and enjoy building these 3 classic examples of Gotham City architecture.", image_align: 'float_left', created_at: Date.today - 2)

# frozen_string_literal: true

task add_pinterest_base_board: :environment do
  Pinterest::Client.new.create_board(
    'Brick City Depot',
    'At Brick City Depot, we make affordable, high quality instructions to help you expand your Lego® collection and building skills.',
    'base_product'
  )
end

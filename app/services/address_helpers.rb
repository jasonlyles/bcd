# frozen_string_literal: true

class AddressHelpers
  def self.countries
    [['United States', 'US']]
  end

  # rubocop:disable Metrics/MethodLength
  def self.states
    Array[%w[Alabama AL],
          %w[Alaska AK],
          ['American Samoa', 'AS'],
          %w[Arizona AZ],
          %w[Arkansas AR],
          %w[California CA],
          %w[Colorado CO],
          %w[Connecticut CT],
          ['District of Columbia', 'DC'],
          %w[Delaware DE],
          %w[Florida FL],
          %w[Georgia GA],
          %w[Guam GU],
          %w[Hawaii HI],
          %w[Idaho ID],
          %w[Illinois IL],
          %w[Indiana IN],
          %w[Iowa IA],
          %w[Kansas KS],
          %w[Kentucky KY],
          %w[Louisiana LA],
          %w[Maine ME],
          %w[Maryland MD],
          %w[Massachusetts MA],
          %w[Michigan MI],
          %w[Minnesota MN],
          %w[Mississippi MS],
          %w[Missouri MO],
          %w[Montana MT],
          %w[Nebraska NE],
          %w[Nevada NV],
          ['New Hampshire', 'NH'],
          ['New Jersey', 'NJ'],
          ['New Mexico', 'NM'],
          ['New York', 'NY'],
          ['North Carolina', 'NC'],
          ['North Dakota', 'ND'],
          %w[Ohio OH],
          %w[Oklahoma OK],
          %w[Oregon OR],
          %w[Pennsylvania PA],
          ['Puerto Rico', 'PR'],
          ['Rhode Island', 'RI'],
          ['South Carolina', 'SC'],
          ['South Dakota', 'SD'],
          %w[Tennessee TN],
          %w[Texas TX],
          %w[Utah UT],
          %w[Vermont VT],
          %w[Virginia VA],
          ['Virgin Islands', 'VI'],
          %w[Washington WA],
          ['West Virginia', 'WV'],
          %w[Wisconsin WI],
          %w[Wyoming WY]]
  end
  # rubocop:enable Metrics/MethodLength
end

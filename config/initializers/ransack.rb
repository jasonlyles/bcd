Ransack.configure do |config|
  config.add_predicate 'datepart_equals',
                       arel_predicate: 'eq',
                       formatter: proc { |v| v.to_s },
                       validator: proc { |v| v.present? },
                       type: :string
end

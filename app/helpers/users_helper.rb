# frozen_string_literal: true

module UsersHelper
  def decorate_account_status(status)
    statuses = {
      'A' => 'Active',
      'C' => 'Cancelled',
      'G' => 'Guest'
    }
    statuses[status]
  end
end

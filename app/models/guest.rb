# frozen_string_literal: true

class Guest < User
  def apply_omniauth
    nil
  end

  def password_required?
    false
  end

  def cancel_account
    nil
  end
end

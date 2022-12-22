# frozen_string_literal: true

module RegistrationsHelper
  def nice_authentications_list(auths)
    auths = auths.map { |auth| auth.provider.capitalize }
    "#{auths.join(' and ')} #{auths.length > 1 ? 'authentications' : 'authentication'}"
  end

  def all_auths_taken(auths)
    !auths.empty? && auths.length == RegistrationsController::MAX_AUTHS_ALLOWED
  end
end

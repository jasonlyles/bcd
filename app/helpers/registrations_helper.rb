module RegistrationsHelper
  def nice_authentications_list(auths)
    auths = auths.map{|x| x.provider.capitalize }
    auths = "#{auths.join(" and ")} #{auths.length > 1 ? "authentications" : "authentication"}"
  end
end

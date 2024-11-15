module ApplicationHelper
  def user_initials(user)
    if user&.first_name.present? || user&.last_name.present?
      [user.first_name.to_s[0], user.last_name.to_s[0]].join.upcase
    else
      "SB"
    end
  end
end

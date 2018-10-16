module ApplicationHelper
  def resource_name
    :user
  end
  def get_user_full_name(user)

  end

  def getuserName(email)
    user=User.find_by_email(email)
    user_name=user.first_name
    return user_name
  end
  def resource
    @resource ||= User.new
  end

  def check_current_page(path)
  return ['search','help','transactions/new','how_it_works','gift_card'].map{|sub_url| path.include?(sub_url)}.include?(true)
  end

  def check_page_for_nav_bar(path)
    return ['search','help','how_it_works','gift_card','professional_sign_up','corporate'].map{|sub_url| path.include?(sub_url)}.include?(true)

  end
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def is_active?(link_path)
    current_page?(link_path) ? "active" : ""
  end
end

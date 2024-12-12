class ComponentsController < ApplicationController
  before_action :authenticate_developer!
  layout 'components'

  def index
    # Add your components and variants here
    @page_title = 'UI Components'
  end

  private

  def authenticate_developer!
    unless Rails.env.development? || (Rails.env.production? && current_user&.admin?)
      redirect_to root_path, alert: 'Not authorized'
    end
  end
end

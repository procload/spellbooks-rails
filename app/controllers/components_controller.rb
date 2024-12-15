class ComponentsController < ApplicationController
  before_action :authenticate_developer!
  layout 'components'

  def index
    # Add your components and variants here
    @page_title = 'UI Components'
    @students = sample_students
  end

  private

  def authenticate_developer!
    unless Rails.env.development? || (Rails.env.production? && Current.user&.admin?)
      redirect_to root_path, alert: 'Not authorized'
    end
  end

  def sample_students
    [
      OpenStruct.new(
        id: 1,
        first_name: "John",
        last_name: "Doe",
        email_address: "john@example.com",
        assignments: OpenStruct.new(count: 3)
      ),
      OpenStruct.new(
        id: 2,
        first_name: "Jane",
        last_name: "Smith",
        email_address: "jane@example.com",
        assignments: OpenStruct.new(count: 5)
      )
    ]
  end
end

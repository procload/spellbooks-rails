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
        first_name: "Alice",
        last_name: "Anderson",
        email_address: "alice@example.com"
      ),
      OpenStruct.new(
        id: 2,
        first_name: "Bob",
        last_name: "Brown",
        email_address: "bob@example.com"
      ),
      OpenStruct.new(
        id: 3,
        first_name: "Charlie",
        last_name: "Chen",
        email_address: "charlie@example.com"
      ),
      OpenStruct.new(
        id: 4,
        first_name: "Diana",
        last_name: "Davis",
        email_address: "diana@example.com"
      ),
      OpenStruct.new(
        id: 5,
        first_name: "Edward",
        last_name: "Evans",
        email_address: "edward@example.com"
      )
    ]
  end
end

require 'ostruct'

module ComponentsHelper
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
      ),
      OpenStruct.new(
        id: 6,
        first_name: "Fiona",
        last_name: "Fisher",
        email_address: "fiona@example.com"
      ),
      OpenStruct.new(
        id: 7,
        first_name: "George",
        last_name: "Garcia",
        email_address: "george@example.com"
      ),
      OpenStruct.new(
        id: 8,
        first_name: "Hannah",
        last_name: "Harris",
        email_address: "hannah@example.com"
      ),
      OpenStruct.new(
        id: 9,
        first_name: "Ian",
        last_name: "Ibrahim",
        email_address: "ian@example.com"
      ),
      OpenStruct.new(
        id: 10,
        first_name: "Julia",
        last_name: "Jones",
        email_address: "julia@example.com"
      )
    ]
  end
end
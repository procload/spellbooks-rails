# Clear existing data
puts "Clearing existing data..."
Answer.destroy_all
Question.destroy_all
Assignment.destroy_all
Session.destroy_all
User.destroy_all

# Create default admin user
puts "Creating default admin user..."
admin = User.create!(
  email_address: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User'
)
puts "Created admin user: #{admin.email_address}"


# Sample assignments data
puts "Creating sample assignments..."
assignments_data = [
  {
    title: "Introduction to Fractions",
    subject: "Math",
    grade_level: 4,
    difficulty: "Easy",
    number_of_questions: 5,
    interests: "games, puzzles",
    status: "completed",
    passage: "Let's learn about fractions through pizza slices!",
    published: true
  },
  {
    title: "Ancient Egypt",
    subject: "History",
    grade_level: 6,
    difficulty: "Medium",
    number_of_questions: 4,
    interests: "archaeology, pyramids",
    status: "completed",
    passage: "Discover the mysteries of ancient Egyptian civilization...",
    published: true
  },
  {
    title: "Basic Forces",
    subject: "Physics",
    grade_level: 8,
    difficulty: "Hard",
    number_of_questions: 3,
    interests: "rockets, space",
    status: "completed",
    passage: "Understanding Newton's laws of motion...",
    published: true
  }
]

# Create assignments with questions and answers
assignments_data.each do |assignment_data|
  puts "Creating assignment: #{assignment_data[:title]}"
  assignment = Assignment.create!(assignment_data)

  # Create sample questions with answers in a transaction
  assignment_data[:number_of_questions].times do |i|
    ActiveRecord::Base.transaction do
      question = assignment.questions.new(
        content: "Sample question #{i + 1} for #{assignment.title}",
        explanation: "This is the explanation for question #{i + 1}"
      )

      # Create 4 answers for the question
      answers_data = [
        { text: "Correct answer for question #{i + 1}", is_correct: true },
        { text: "Incorrect answer 1 for question #{i + 1}", is_correct: false },
        { text: "Incorrect answer 2 for question #{i + 1}", is_correct: false },
        { text: "Incorrect answer 3 for question #{i + 1}", is_correct: false }
      ]

      answers_data.each do |answer_data|
        question.answers.build(answer_data)
      end

      question.save!
    end
  end
end

# Create a teacher
teacher = User.create!(
  email_address: "teacher@example.com",
  password: "password123",
  role: "teacher",
  first_name: "Test",
  last_name: "Teacher"
)

# Create some students
students = 3.times.map do |i|
  User.create!(
    email_address: "student#{i+1}@example.com",
    password: "password123",
    role: "student",
    first_name: "Student",
    last_name: "#{i+1}"
  )
end

# Create an assignment
assignment = Assignment.create!(
  title: "Math Quiz",
  subject: "Mathematics",
  grade_level: 9,
  difficulty: "Medium",
  number_of_questions: 10,
  interests: "Algebra",
  published: true
)

# Associate the assignment with the teacher
AssignmentUser.create!(
  assignment: assignment,
  user: teacher,
  role: "creator"
)

# Assign to students
students.each do |student|
  AssignmentUser.create!(
    assignment: assignment,
    user: student,
    role: "student"
  )
end

puts "Seed data created successfully!"
puts "Created:"
puts "- #{User.count} users"
puts "- #{Assignment.count} assignments"
puts "- #{Question.count} questions"
puts "- #{Answer.count} answers"

puts "\nYou can login with:"
puts "Email: admin@example.com"
puts "Password: password123"

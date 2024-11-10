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
  password_confirmation: 'password123'
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
    passage: "Let's learn about fractions through pizza slices!"
  },
  {
    title: "Ancient Egypt",
    subject: "History",
    grade_level: 6,
    difficulty: "Medium",
    number_of_questions: 4,
    interests: "archaeology, pyramids",
    status: "completed",
    passage: "Discover the mysteries of ancient Egyptian civilization..."
  },
  {
    title: "Basic Forces",
    subject: "Physics",
    grade_level: 8,
    difficulty: "Hard",
    number_of_questions: 3,
    interests: "rockets, space",
    status: "completed",
    passage: "Understanding Newton's laws of motion..."
  }
]

# Create assignments with questions and answers
assignments_data.each do |assignment_data|
  puts "Creating assignment: #{assignment_data[:title]}"
  assignment = Assignment.create!(assignment_data)

  # Create sample questions for each assignment
  assignment_data[:number_of_questions].times do |i|
    question = assignment.questions.create!(
      content: "Sample question #{i + 1} for #{assignment.title}",
      explanation: "This is the explanation for question #{i + 1}"
    )

    # Create 4 answers for each question (1 correct, 3 incorrect)
    4.times do |j|
      question.answers.create!(
        text: "Answer option #{j + 1}",
        is_correct: (j == 0) # First answer is correct
      )
    end
  end
end

# Create a teacher
teacher = User.create!(
  email_address: "teacher@example.com",
  password: "password123",
  role: "teacher"
)

# Create some students
students = 3.times.map do |i|
  User.create!(
    email_address: "student#{i+1}@example.com",
    password: "password123",
    role: "student"
  )
end

# Create an assignment
assignment = Assignment.create!(
  title: "Math Quiz",
  subject: "Mathematics",
  grade_level: 9,
  difficulty: "Medium",
  number_of_questions: 10,
  interests: "Algebra"
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

require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @assignment = create(:assignment)
    create(:assignment_user, user: @teacher, assignment: @assignment, role: 'creator')
  end

  test "can create assignment with valid attributes" do
    assignment = build(:assignment)
    assert assignment.valid?
  end

  test "cannot create assignment without title" do
    assignment = build(:assignment, title: nil)
    assert_not assignment.valid?
    assert_includes assignment.errors[:title], "can't be blank"
  end

  test "assignment belongs to teacher through assignment_users" do
    assert_includes @assignment.teachers, @teacher
  end

  test "cached_pdf is purged when relevant attributes change" do
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    assert @assignment.cached_pdf.attached?
    
    @assignment.update!(title: "New Title")
    assert_not @assignment.cached_pdf.attached?
  end

  test "cached_pdf is not purged when non-relevant attributes change" do
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    assert @assignment.cached_pdf.attached?
    
    @assignment.update!(created_at: Time.current)
    assert @assignment.cached_pdf.attached?
  end

  test "cached_pdf is purged when a question is updated" do
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    question = create(:question, :skip_validations, assignment: @assignment)
    create(:answer, :correct, question: question)
    create(:answer, :incorrect, question: question)
    
    assert @assignment.cached_pdf.attached?
    
    question.update!(content: "New question content")
    assert_not @assignment.cached_pdf.attached?
  end

  test "cached_pdf is purged when an answer is updated" do
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    question = create(:question, :skip_validations, assignment: @assignment)
    answer1 = create(:answer, :correct, question: question)
    answer2 = create(:answer, :incorrect, question: question)
    
    assert @assignment.cached_pdf.attached?
    
    answer1.update!(text: "New answer text")
    assert_not @assignment.cached_pdf.attached?
  end

  test "cached_pdf is purged when a question is deleted" do
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    question = create(:question, :skip_validations, assignment: @assignment)
    create(:answer, :correct, question: question)
    create(:answer, :incorrect, question: question)
    
    assert @assignment.cached_pdf.attached?
    
    question.destroy
    assert_not @assignment.cached_pdf.attached?
  end

  test "cached_pdf is purged when an answer is deleted" do
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    question = create(:question, :skip_validations, assignment: @assignment)
    answer1 = create(:answer, :correct, question: question)
    answer2 = create(:answer, :incorrect, question: question)
    
    assert @assignment.cached_pdf.attached?
    
    answer1.destroy
    assert_not @assignment.cached_pdf.attached?
  end
end

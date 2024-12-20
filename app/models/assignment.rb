class Assignment < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_one_attached :image
  
  has_many :assignment_users, dependent: :destroy
  has_many :users, through: :assignment_users
  has_many :teachers, -> { where(assignment_users: { role: 'creator' }) }, through: :assignment_users, source: :user
  
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :subject, presence: true
  validates :grade_level, presence: true, 
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 12 }
  validates :difficulty, presence: true, inclusion: { in: ['Easy', 'Medium', 'Hard'] }
  validates :number_of_questions, presence: true, 
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :interests, presence: true, length: { maximum: 1000 }
  
  # Only validate image if it's attached
  validates :image,
            attached: false,
            content_type: [:png, :jpg, :jpeg],
            size: { less_than: 5.megabytes },
            if: :image_attached?

  validates :assignment_users, presence: true, on: :update

  after_update :remove_cached_pdf, if: :relevant_attributes_changed?

  attr_accessor :updated_by_id
  
  validates :status, presence: true, 
                    inclusion: { in: %w[pending in_progress completed] }

  def processing?
    status == 'in_progress'
  end

  def student_ids
    students.pluck(:id)
  end

  def attach_image_from_url(url)
    require 'open-uri'
    begin
      Rails.logger.info "Attempting to download image from URL: #{url}"
      downloaded_image = URI.open(url)
      Rails.logger.info "Successfully downloaded image, attaching to assignment #{id}"
      
      image.attach(io: downloaded_image, filename: "assignment_#{id}_image.jpg")
      
      if image.attached?
        Rails.logger.info "Image successfully attached. Storage service: #{Rails.application.config.active_storage.service}"
        variant = image.variant(resize_to_limit: [800, 600])
        Rails.logger.info "Image variant created successfully"
        true
      else
        Rails.logger.error "Failed to attach image - no attachment created"
        false
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.error "Failed to download image: #{e.message}"
      false
    rescue StandardError => e
      Rails.logger.error "Error attaching image: #{e.message}"
      false
    end
  end

  def display_image
    if image.attached?
      Rails.logger.debug "Generating variant for image: #{image.filename}"
      if Rails.application.config.active_storage.service == :amazon
        image.url(expires_in: 1.hour)
      else
        image.variant(resize_to_limit: [800, 600])
      end
    else
      Rails.logger.warn "Attempted to display_image but no image is attached"
      nil
    end
  end

  def cached_image_variant
    return nil unless image.attached?
    
    begin
      image.variant(
        resize_to_limit: [800, 600],
        saver: { quality: 90 }
      ).processed
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error "Image file not found for Assignment #{id}: #{e.message}"
      image.purge if Rails.env.development? # Clean up the attachment if file is missing
      nil
    end
  end

  # Helper methods for teacher/student relationships
  def teachers
    users.joins(:assignment_users)
        .where(assignment_users: { role: 'creator' })
  end
  
  def students
    users.joins(:assignment_users)
        .where(assignment_users: { role: 'student' })
        .distinct
  end
  
  def assign_to_students(student_ids, current_user)
    return false unless current_user.teacher?
    
    student_ids = Array(student_ids).map(&:to_i)
    
    transaction do
      # Remove students that are no longer selected
      assignment_users.students.where.not(user_id: student_ids).destroy_all
      
      # Add new students without creating duplicates
      student_ids.each do |student_id|
        # Only assign students that belong to this teacher
        if current_user.students.exists?(student_id)
          assignment_users.students.find_or_create_by!(
            user_id: student_id,
            role: 'student'
          ) do |au|
            au.status = 'pending'
          end
        end
      end
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def student_progress(student)
    return nil unless student
    
    assignment_user = assignment_users.find_by(user: student, role: 'student')
    return nil unless assignment_user
    
    {
      status: assignment_user.status,
      answered_questions: assignment_user.student_answers.count,
      total_questions: questions.count,
      correct_answers: assignment_user.student_answers.where(correct: true).count
    }
  end

  def remove_cached_pdf
    cached_pdf.purge if cached_pdf.attached?
  end

  def relevant_attributes_changed?
    saved_changes.keys.any? { |attr| ['title', 'subject', 'grade_level', 'difficulty', 'number_of_questions', 'interests'].include?(attr) }
  end

  def markdown_passage
    self[:markdown_passage].presence || passage
  end

  def enqueue_processing
    return false if status != 'pending'
    
    with_lock do
      if status == 'pending'
        update!(status: 'in_progress')
        ProcessAssignmentJob.perform_later(id)
        true
      else
        false
      end
    end
  end

  def grade_level=(value)
    if value.include?(',')
      # For segmented control multi-grade selections
      super(value.split(',').first)
    else
      super(value)
    end
  end

  private

  def image_attached?
    image.attached?
  end

  def process_image
    image.variant(resize_to_limit: [800, 600]).processed
  end

  def safe_image_url
    return nil unless image.attached?
    
    begin
      Rails.application.routes.url_helpers.url_for(image)
    rescue StandardError => e
      Rails.logger.error "Error generating image URL: #{e.message}"
      nil
    end
  end

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }

  def publish!
    update!(published: true)
  end

  def unpublish!
    update!(published: false)
  end
end

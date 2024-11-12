class Assignment < ApplicationRecord
  broadcasts_to ->(assignment) { "assignments" }
  
  has_many :questions, dependent: :destroy
  has_one_attached :image
  
  has_many :assignment_users, dependent: :destroy
  has_many :users, through: :assignment_users
  
  validates :title, presence: true
  validates :subject, presence: true
  validates :grade_level, presence: true, inclusion: { in: 0..12 }
  validates :difficulty, presence: true
  validates :number_of_questions, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :interests, presence: true
  
  # Only validate image if it's attached
  validates :image,
            attached: false,
            content_type: [:png, :jpg, :jpeg],
            size: { less_than: 5.megabytes },
            if: :image_attached?

  after_create_commit :process_assignment

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
    Rails.cache.fetch("assignment/#{id}/image_variant", expires_in: 1.hour) do
      display_image
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
  end
  
  def assign_to_students(student_ids, current_user)
    return false unless current_user.teacher?
    
    transaction do
      # Remove students that are no longer selected
      assignment_users.students.where.not(user_id: student_ids).destroy_all
      
      # Add new students
      student_ids.each do |student_id|
        assignment_users.students.find_or_create_by!(
          user_id: student_id,
          role: 'student'
        )
      end
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def image_attached?
    image.attached?
  end

  def process_assignment
    ProcessAssignmentJob.perform_later(id)
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
end

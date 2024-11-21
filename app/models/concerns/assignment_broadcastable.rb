module AssignmentBroadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_to ->(assignment) { "assignments" }
    after_update_commit :broadcast_status_change, if: :saved_change_to_status?
  end

  private

  def broadcast_status_change
    return unless updated_by_id # Only broadcast if we know who updated it

    teachers.each do |teacher|
      broadcast_prepend_later_to(
        "assignments:#{teacher.id}",
        target: "toasts",
        partial: "shared/toast",
        locals: {
          type: "info",
          message: status_change_message,
          auto_hide: true
        }
      )
    end
  end

  def status_change_message
    student = User.find(updated_by_id)
    "#{student.name} has marked '#{title}' as #{status}"
  end
end 
class AssignmentPolicy < ApplicationPolicy
  def update_status?
    # Only allow students assigned to this assignment to update its status
    record.students.include?(user)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end 
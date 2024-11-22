module AssignmentsHelper
  def assignment_card_color(subject)
    case subject&.downcase
    when 'math'
      'bg-spellbooks-subject-math'
    when 'science'
      'bg-spellbooks-subject-science'
    when 'english'
      'bg-spellbooks-subject-english'
    when 'history'
      'bg-spellbooks-subject-history'
    else
      'bg-spellbooks-subject-default'
    end
  end

  def assignment_due_text(assignment)
    return 'Completed' if assignment.status == 'completed'
    
    if assignment.respond_to?(:due_date) && assignment.due_date.present?
      days_until_due = (assignment.due_date.to_date - Date.current).to_i
      case days_until_due
      when 0
        'Due today'
      when 1
        'Due tomorrow'
      when 2..5
        "Due in #{days_until_due} days"
      else
        assignment.due_date.strftime('%b %d')
      end
    else
      assignment.status.titleize
    end
  end
end

module AssignmentsHelper
  def assignment_card_color(subject)
    case subject&.downcase
    when 'math'
      'bg-white border border-gray-50 border-l-2 border-l-lochmara-200/60'
    when 'science'
      'bg-white border border-gray-50 border-l-2 border-l-punch-200/60'
    when 'english'
      'bg-white border border-gray-50 border-l-2 border-l-bunker-200/60'
    when 'history'
      'bg-white border border-gray-50 border-l-2 border-l-lochmara-200/60'
    when 'art'
      'bg-white border border-gray-50 border-l-2 border-l-punch-200/60'
    else
      'bg-white border border-gray-50 border-l-2 border-l-bunker-200/60'
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

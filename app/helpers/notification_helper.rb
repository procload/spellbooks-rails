module NotificationHelper
  def type_classes(type)
    case type.to_s
    when 'success'
      'bg-green-100 border-l-4 border-green-500 text-green-700'
    when 'error'
      'bg-red-100 border-l-4 border-red-500 text-red-700'
    else
      'bg-blue-100 border-l-4 border-blue-500 text-blue-700'
    end
  end
end
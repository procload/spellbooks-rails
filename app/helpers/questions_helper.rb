module QuestionsHelper
  def question_status_classes(answer, is_correct)
    if is_correct
      "border-green-500 bg-green-50"
    else
      "border-gray-200"
    end
  end

  def feedback_classes(correct)
    base_classes = "mt-4 p-4 rounded-lg"
    status_classes = correct ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
    "#{base_classes} #{status_classes}"
  end

  def question_button_classes
    "inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 " \
    "font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none " \
    "focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
  end

  def submit_button_classes
    "px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors duration-200"
  end

  def answer_label_classes(answer)
    "block p-4 border border-gray-200 rounded-lg cursor-pointer hover:border-blue-500 " \
    "peer-checked:border-blue-500 peer-checked:bg-blue-50 transition-colors duration-200"
  end
end 
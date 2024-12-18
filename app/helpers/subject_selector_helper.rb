module SubjectSelectorHelper
  def subject_icon(name)
    case name.to_s.downcase
    when 'math'
      icon("calculator", library: "heroicons", class: "text-black")
    when 'science'
      icon("beaker", library: "heroicons", class: "text-black")
    when 'english'
      icon("book-open", library: "heroicons", class: "text-black")
    when 'history'
      icon("globe-americas", library: "heroicons", class: "text-black")
    when 'art'
      icon("paint-brush", library: "heroicons", class: "text-black")
    else
      icon("academic-cap", library: "heroicons", class: "text-black")
    end
  end
end
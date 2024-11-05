class PromptMapperService
  SUBJECT_TO_PROMPT_MAPPING = {
    'reading comprehension' => 'english',
    'creative writing' => 'english',
    'grammar' => 'english',
    'literature' => 'english',
    'algebra' => 'math',
    'geometry' => 'math',
    'arithmetic' => 'math',
    'calculus' => 'math',
    'physics' => 'science',
    'chemistry' => 'science',
    'biology' => 'science',
    'earth science' => 'science',
    'art' => 'art',
		'history' => 'history'
  }.freeze

  def self.get_prompt_filename(subject)
    Rails.logger.info "PromptMapper: Mapping subject '#{subject}'"
    return "english.txt" if subject.nil?
    
    mapped_subject = SUBJECT_TO_PROMPT_MAPPING[subject.downcase] || subject.downcase
    Rails.logger.info "PromptMapper: Mapped '#{subject}' to '#{mapped_subject}'"
    
    filename = "#{mapped_subject}.txt"
    Rails.logger.info "PromptMapper: Final filename: #{filename}"
    filename
  end
end 
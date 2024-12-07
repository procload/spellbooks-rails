# Load all LLM-related files
Dir[Rails.root.join('app', 'services', 'llm', '**', '*.rb')].sort.each do |file|
  require file
end 
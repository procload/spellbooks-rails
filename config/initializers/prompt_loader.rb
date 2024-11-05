Rails.application.config.to_prepare do
  prompt_path = Rails.root.join('lib', 'prompts')
  Dir[prompt_path.join('*.txt')].each do |file|
    Rails.application.config.assets.paths << File.dirname(file)
  end
end 
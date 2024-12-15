class GenerateMarkdownJob < ApplicationJob
  queue_as :default
  
  def perform(assignment_id)
    assignment = Assignment.find(assignment_id)
    return unless assignment.passage.present?
    
    Rails.logger.info "[GenerateMarkdownJob] Generating markdown for passage: #{assignment.passage[0..100]}..."
    
    provider = LLM::Factory.create_provider
    response = provider.chat(
      messages: [
        { role: 'system', content: MarkdownPromptService.system_prompt },
        { role: 'user', content: MarkdownPromptService.generate_prompt(assignment.passage) }
      ]
    )
    
    if response.present?
      Rails.logger.info "[GenerateMarkdownJob] Markdown generated successfully"
      assignment.update!(markdown_passage: response)
    else
      Rails.logger.warn "[GenerateMarkdownJob] No markdown response from provider"
    end
  rescue => e
    Rails.logger.error "[GenerateMarkdownJob] Error generating markdown: #{e.message}"
    Rails.logger.error "[GenerateMarkdownJob] #{e.backtrace.first(5).join("\n")}"
    raise
  end
end
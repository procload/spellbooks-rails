class GenerateMarkdownJob < ApplicationJob
  queue_as :default
  
  def perform(assignment_id)
    assignment = Assignment.find(assignment_id)
    return unless assignment.passage.present?
    
    client = OpenAI::Client.new(
      access_token: ENV.fetch('OPENAI_API_KEY'),
      request_timeout: 240
    )
    
    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: MarkdownPromptService.system_prompt },
          { role: "user", content: MarkdownPromptService.generate_prompt(assignment.passage) }
        ]
      }
    )
    
    markdown_content = response.dig("choices", 0, "message", "content")
    
    if markdown_content.present?
      assignment.update!(markdown_passage: markdown_content)
    end
  rescue => e
    Rails.logger.error "Error generating markdown: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end 
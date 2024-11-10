class GenerateMarkdownJob < ApplicationJob
  queue_as :default
  
  retry_on OpenAI::Error, wait: 5.seconds, attempts: 3
  
  def perform(assignment_id)
    assignment = Assignment.find(assignment_id)
    return if assignment.passage.blank?
    
    client = OpenAI::Client.new(
      access_token: ENV.fetch('OPENAI_API_KEY'),
      request_timeout: 240
    )
    
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: MarkdownPromptService.system_prompt },
          { role: "user", content: MarkdownPromptService.generate_prompt(assignment.passage) }
        ]
      }
    )
    
    markdown_content = response.dig("choices", 0, "message", "content")
    assignment.update!(markdown_passage: markdown_content) if markdown_content.present?
  end
end 
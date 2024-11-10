class MarkdownPromptService
  def self.system_prompt
    <<~PROMPT
      You are a specialized formatting assistant. Your task is to convert educational content 
      into well-structured markdown format. Follow these guidelines:
      
      1. Use appropriate heading levels (# for main titles, ## for subtitles)
      2. Convert lists into proper markdown bullet points or numbered lists
      3. Add emphasis (* or **) for important terms or concepts
      4. Preserve all educational content exactly as provided
      5. Add appropriate line breaks for readability
      6. Format any examples or special sections with appropriate markdown
      7. Do not add or remove any actual content - only format existing content
    PROMPT
  end

  def self.generate_prompt(passage)
    <<~PROMPT
      Please convert the following educational passage into well-formatted markdown. 
      Maintain all original content but enhance readability with appropriate markdown formatting:

      #{passage}
    PROMPT
  end
end 
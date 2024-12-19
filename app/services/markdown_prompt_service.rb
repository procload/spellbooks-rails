class MarkdownPromptService
  def self.system_prompt
    "You are a helpful assistant that converts text to markdown format. Never include markdown language indicators like '```markdown' at the start of the content."
  end

  def self.generate_prompt(passage)
    <<~PROMPT
      Convert the following educational passage into markdown format. 
      Do not include markdown language indicators (like ```markdown) at the start or end of the content.
      Use appropriate markdown syntax for:
      - Headers (##, ###)
      - Lists (both ordered and unordered where appropriate)
      - Bold and italic text for emphasis
      - Block quotes for important points
      - Tables if data is presented
      
      Keep the content exactly the same, just add appropriate markdown formatting.
      
      Passage:
      #{passage}
    PROMPT
  end
end 
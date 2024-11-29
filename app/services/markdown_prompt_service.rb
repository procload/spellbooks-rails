class MarkdownPromptService
  def self.system_prompt
    "You are a helpful assistant that converts text to markdown format."
  end

  def self.generate_prompt(passage)
    <<~PROMPT
      Convert the following educational passage into markdown format. 
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
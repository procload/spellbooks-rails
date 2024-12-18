class ImagePromptService
  def self.generate_prompt(assignment)
    "Create a minimalist educational coloring book page illustration featuring elements related to #{assignment.interests}. The style should be clean, simple black line art on a white background, resembling a beginner-friendly coloring page. The artwork should be well-composed, with clear details, monochrome, and high contrast. Combine recognizable features or objects from #{assignment.interests} into a balanced, easy-to-color design. Exclude unnecessary details or complex backgrounds to maintain simplicity. Ensure the image is appropriate for children."
  end
end 


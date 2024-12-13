class InterestsService
  class << self
    def all_interests
      @all_interests ||= begin
        interests_hash = YAML.load_file(Rails.root.join('config', 'interests.yml'))
        interests_hash['interests'].values.flatten.sort
      end
    end

    def suggest(query)
      return all_interests if query.blank?
      
      query = query.downcase
      all_interests.select do |interest|
        interest.downcase.include?(query)
      end
    end

    def categorized_interests
      @categorized_interests ||= begin
        interests_hash = YAML.load_file(Rails.root.join('config', 'interests.yml'))
        interests_hash['interests']
      end
    end
  end
end 
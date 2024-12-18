class InterestsController < ApplicationController
  def suggestions
    query = params[:query]
    suggestions = InterestsService.suggest(query)
    
    respond_to do |format|
      format.json { render json: suggestions }
      format.turbo_stream {
        render turbo_stream: turbo_stream.update(
          'interest-suggestions',
          partial: 'interests/suggestions',
          locals: { suggestions: suggestions }
        )
      }
    end
  end

  def random
    # Get all interests that aren't currently in use
    used_interests = params[:used_interests]&.split(',')&.map(&:strip) || []
    available_interests = InterestsService.all_interests - used_interests
    
    if available_interests.any?
      render json: { interest: available_interests.sample }
    else
      render json: { interest: nil }
    end
  end
end
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
end 
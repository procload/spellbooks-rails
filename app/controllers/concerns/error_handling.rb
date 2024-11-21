module ErrorHandling
  extend ActiveSupport::Concern

  private

  def handle_turbo_stream_error(record, error, counter = nil)
    Rails.logger.error "Error: #{error.message}"
    Rails.logger.error "Full error details: #{error.inspect}"
    Rails.logger.error "Backtrace: #{error.backtrace.join("\n")}"
    
    locals = { record.class.name.underscore.to_sym => record }
    locals[:question_counter] = counter if counter

    render turbo_stream: turbo_stream.replace(
      dom_id(record),
      partial: record.class.name.underscore,
      locals: locals
    ), status: :unprocessable_entity
  end

  def handle_validation_error(record, error)
    respond_to do |format|
      format.html { 
        flash.now[:alert] = "Validation failed: #{error.message}"
        render :edit 
      }
      format.json { 
        render json: { 
          success: false, 
          errors: record.errors.full_messages 
        }, status: :unprocessable_entity 
      }
      format.turbo_stream { 
        handle_turbo_stream_error(record, error)
      }
    end
  end
end 
# app/channels/turbo/streams_channel.rb
class Turbo::StreamsChannel < ApplicationCable::Channel
  def subscribed
    if verified_stream_name = verify_stream_name
      stream_from verified_stream_name
      logger.info "[Turbo::StreamsChannel] Successfully subscribed #{current_user.id} to #{verified_stream_name}"
    else
      logger.error "[Turbo::StreamsChannel] Subscription rejected for #{current_user.id}"
      reject
    end
  end

  private

  def verify_stream_name
    return unless params[:signed_stream_name]

    Turbo::StreamsChannel.verified_stream_name(params[:signed_stream_name])
  rescue Turbo::Streams::InvalidSignatureError => error
    logger.error "[Turbo::StreamsChannel] Invalid stream signature: #{error.message}"
    nil
  end
end
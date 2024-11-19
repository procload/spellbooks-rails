import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    channel: String,
  };

  connect() {
    console.log("[TurboStream] Connected, subscribing to:", this.channelValue);
    this.subscribe();
  }

  disconnect() {
    console.log("[TurboStream] Disconnected, unsubscribing");
    if (this.subscription) {
      this.subscription.unsubscribe();
      this.subscription = null;
    }
  }

  subscribe() {
    // Only subscribe if we haven't already
    if (!this.subscription) {
      this.subscription = this.application.consumer.subscriptions.create(
        {
          channel: "Turbo::StreamsChannel",
          signed_stream_name: this.channelValue,
        },
        {
          received: (data) => {
            console.log("[TurboStream] Received message:", data);
            // Process the incoming Turbo Stream
            Turbo.renderStreamMessage(data);
          },
          disconnected: () => {
            console.log("[TurboStream] Disconnected from:", this.channelValue);
          },
          connected: () => {
            console.log("[TurboStream] Connected to:", this.channelValue);
          },
        }
      );
    }
  }
}

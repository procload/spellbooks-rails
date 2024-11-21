import { Controller } from "@hotwired/stimulus";
import { createConsumer } from "@rails/actioncable";

export default class extends Controller {
  static values = {
    assignmentsChannel: String,
    teacherChannel: String,
  };

  connect() {
    console.log("[TurboStream] Controller connected");
    this.consumer = createConsumer();

    if (this.hasAssignmentsChannelValue) {
      console.log(
        "[TurboStream] Connecting to assignments channel:",
        this.assignmentsChannelValue
      );
      this.assignmentsSubscription = this.consumer.subscriptions.create(
        {
          channel: "Turbo::StreamsChannel",
          signed_stream_name: this.assignmentsChannelValue,
        },
        {
          received: (data) => {
            console.log("[TurboStream] Received data on assignments channel:", {
              messageType: data.type,
              content: data.content,
              fullData: data,
            });
            Turbo.renderStreamMessage(data);
          },
        }
      );
    }

    if (this.hasTeacherChannelValue) {
      console.log(
        "[TurboStream] Connecting to teacher channel:",
        this.teacherChannelValue
      );
      this.teacherSubscription = this.consumer.subscriptions.create(
        {
          channel: "Turbo::StreamsChannel",
          signed_stream_name: this.teacherChannelValue,
        },
        {
          received: (data) => {
            console.log("[TurboStream] Received data on teacher channel:", {
              messageType: data.type,
              content: data.content,
              fullData: data,
            });
            Turbo.renderStreamMessage(data);
          },
        }
      );
    }
  }

  disconnect() {
    console.log("[TurboStream] Controller disconnecting");

    if (this.assignmentsSubscription) {
      console.log("[TurboStream] Unsubscribing from assignments channel");
      this.assignmentsSubscription.unsubscribe();
    }

    if (this.teacherSubscription) {
      console.log("[TurboStream] Unsubscribing from teacher channel");
      this.teacherSubscription.unsubscribe();
    }

    if (this.consumer) {
      console.log("[TurboStream] Disconnecting consumer");
      this.consumer.disconnect();
    }
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("[Debug] Connected to Turbo Streams:");
    const streams = document.querySelectorAll("turbo-cable-stream-source");
    streams.forEach((stream) => {
      console.log(
        `[Debug] Stream connected: ${stream.getAttribute(
          "channel"
        )} - ${stream.getAttribute("signed-stream-name")}`
      );
    });
  }
}

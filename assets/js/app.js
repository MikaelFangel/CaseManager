// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// LiveView hooks
const hooks = {
  CopyToClipboard: {
    mounted() {
      this.el.addEventListener("click", () => {
        const targetId = this.el.dataset.target;
        const targetElement = document.getElementById(targetId);

        if (targetElement) {
          const text = targetElement.innerText || targetElement.textContent;

          navigator.clipboard
            .writeText(text)
            .then(() => {
              // Optional: trigger a LiveView event to show feedback
              this.pushEvent("api_key_copied", {});

              // Visual feedback - temporarily change button text
              const originalHTML = this.el.innerHTML;
              this.el.innerHTML =
                '<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>';

              setTimeout(() => {
                this.el.innerHTML = originalHTML;
              }, 1500);
            })
            .catch((err) => {
              console.error("Failed to copy text: ", err);
            });
        }
      });
    },
  },
  CtrlEnterSubmit: {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
          this.el.form.dispatchEvent(
            new Event("submit", { bubbles: true, cancelable: true }),
          );
        }
      });
    },
  },
  PlatformDetector: {
    mounted() {
      this.detectPlatform();
    },

    async detectPlatform() {
      let isMac = false;
      let shouldUseFallback = true;

      // Try modern User-Agent Client Hints API first
      if (navigator.userAgentData) {
        try {
          const platformInfo =
            await navigator.userAgentData.getHighEntropyValues(["platform"]);
          isMac = platformInfo.platform?.toLowerCase() === "macos";
          shouldUseFallback = false;
        } catch (error) {
          console.warn(
            "Failed to get platform info from userAgentData:",
            error,
          );
        }
      }

      // Fallback to userAgent if modern API isn't available or failed
      if (shouldUseFallback) {
        isMac = /mac/i.test(navigator.userAgent);
      }

      this.pushEvent("platform_detected", { is_mac: isMac });
    },
  },
};

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// Handle modal close events from LiveView
window.addEventListener("phx:close-modal", (e) => {
  const modal = document.getElementById(e.detail.id);
  if (modal && modal.close) {
    modal.close();
  }
});

// Handle modal open events from LiveView
window.addEventListener("phx:open-modal", (e) => {
  const modal = document.getElementById(e.detail.id);
  if (modal && modal.showModal) {
    modal.showModal();
  }
});

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener(
    "phx:live_reload:attached",
    ({ detail: reloader }) => {
      // Enable server log streaming to client.
      // Disable with reloader.disableServerLogs()
      reloader.enableServerLogs();

      // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
      //
      //   * click with "c" key pressed to open at caller location
      //   * click with "d" key pressed to open at function component definition location
      let keyDown;
      window.addEventListener("keydown", (e) => (keyDown = e.key));
      window.addEventListener("keyup", (e) => (keyDown = null));
      window.addEventListener(
        "click",
        (e) => {
          if (keyDown === "c") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtCaller(e.target);
          } else if (keyDown === "d") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtDef(e.target);
          }
        },
        true,
      );

      window.liveReloader = reloader;
    },
  );
}

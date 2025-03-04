let Hooks = {};

Hooks.DeselectCheckbox = {
  mounted() {
    this.handleEvent("deselect-checkbox", ({ checkbox_id }) => {
      if (this.el.id == checkbox_id) {
        this.el.checked = false;
      }
    });
  },
};

Hooks.DraggableScroll = {
  mounted() {
    const container = this.el;
    const wrapper = document.getElementById("cards-wrapper");

    let isDown = false;
    let startX;
    let scrollLeft;

    wrapper.addEventListener("mousedown", (e) => {
      isDown = true;
      wrapper.classList.add("active");
      startX = e.pageX - container.offsetLeft;
      scrollLeft = container.scrollLeft;
    });

    wrapper.addEventListener("mouseleave", () => {
      isDown = false;
      wrapper.classList.remove("active");
    });

    wrapper.addEventListener("mouseup", () => {
      isDown = false;
      wrapper.classList.remove("active");
    });

    wrapper.addEventListener("mousemove", (e) => {
      if (!isDown) return;
      e.preventDefault();
      const x = e.pageX - container.offsetLeft;
      const walk = (x - startX) * 2; // Scroll speed multiplier
      container.scrollLeft = scrollLeft - walk;
    });

    // Touch events for mobile
    wrapper.addEventListener(
      "touchstart",
      (e) => {
        isDown = true;
        wrapper.classList.add("active");
        startX = e.touches[0].pageX - container.offsetLeft;
        scrollLeft = container.scrollLeft;
      },
      { passive: true },
    );

    wrapper.addEventListener("touchend", () => {
      isDown = false;
      wrapper.classList.remove("active");
    });

    wrapper.addEventListener("touchcancel", () => {
      isDown = false;
      wrapper.classList.remove("active");
    });

    wrapper.addEventListener(
      "touchmove",
      (e) => {
        if (!isDown) return;
        const x = e.touches[0].pageX - container.offsetLeft;
        const walk = (x - startX) * 2;
        container.scrollLeft = scrollLeft - walk;
      },
      { passive: true },
    );
  },
};

export default Hooks;

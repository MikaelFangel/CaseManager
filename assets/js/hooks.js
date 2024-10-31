let Hooks = {}

Hooks.DeselectCheckbox = {
  mounted() {
    this.handleEvent("deselect-checkbox", ({ checkbox_id }) => {
      if (this.el.id == checkbox_id) {
        this.el.checked = false;
      }
    });
  }
}

export default Hooks;

const themeToggle = {
  // Config
  storageKey: "huggingface-data-theme",
  firstClick: true,

  // Init
  init(key) {
    if (key) {
      this.storageKey = key;
    }
    this.firstClick = true;
    window.localStorage?.setItem(this.storageKey, document.documentElement.dataset?.theme || "auto");
    document.getElementById("theme-toggle-icon")?.addEventListener(
      "click",
      (event) => {
        event.preventDefault();
        this.toggleTheme();
      },
      false,
    );
  },

  toggleTheme() {
    const preferred =
      window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    const current = document.documentElement.dataset?.theme || "auto";
    var next = "auto";
    if (current === "auto") {
      next = preferred === "dark" ? "light" : "dark";
    } else if (this.firstClick) {
      next = current === "dark" ? "light" : "dark";
      this.firstClick = false;
    } else if (preferred === current) {
      next = "auto";
    } else {
      next = preferred;
    }
    window.localStorage?.setItem(this.storageKey, next);
    document.documentElement.dataset.theme = next;
  },
};

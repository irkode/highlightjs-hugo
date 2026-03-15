const themeToggle = {
  // Config
  localStorageKey: "huggingface-data-theme",

  // Init
  init() {
    document.getElementById("theme-toggle")?.addEventListener("click", (event) => {
      event.preventDefault();
      this.toggleTheme();
    }, false);
  },

  toggleTheme() {
    const preferred = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? "dark" : "light";
    const saved = window.localStorage?.getItem(this.localStorageKey) || null
    const current = document.documentElement.dataset?.theme || null
    if ((saved || current) && (!current || current === preferred)) {
      window.localStorage?.removeItem(this.localStorageKey);
      document.documentElement.removeAttribute("data-theme");
    } else {
      var next = saved || current ? preferred : (preferred === "dark" ? "light" : "dark");
      window.localStorage?.setItem(this.localStorageKey, next);
      document.documentElement.dataset.theme = next;
    }
  }
};

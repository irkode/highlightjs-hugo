import * as h4hParams from '@params';

let firstClick = true;
const storageKey = h4hParams.storageKey;

const toggleTheme = () => {
  const preferred = window.matchMedia?.("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
  const current = document.documentElement.dataset?.theme || "auto";
  let next = "auto";

  if (current === "auto") {
    next = preferred === "dark" ? "light" : "dark";
  } else if (firstClick) {
    next = current === "dark" ? "light" : "dark";
    firstClick = false;
  } else if (preferred === current) {
    next = "auto";
  } else {
    next = preferred;
  }

  window.localStorage?.setItem(storageKey, next);
  document.documentElement.dataset.theme = next;
};

window.localStorage?.setItem(storageKey, document.documentElement.dataset?.theme || "auto");
document.getElementById("theme-toggle-icon")?.addEventListener("click", (e) => {
  e.preventDefault();
  toggleTheme();
}, false);
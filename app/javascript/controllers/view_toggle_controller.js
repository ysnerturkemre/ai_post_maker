import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["grid", "gridButton", "listButton"];

  connect() {
    const mode = window.localStorage.getItem("galleryViewMode") || "grid";
    if (mode === "list") {
      this.list();
    } else {
      this.grid();
    }
  }

  grid() {
    this.gridTarget.classList.remove("is-list");
    this.gridButtonTarget.classList.add("is-active");
    this.listButtonTarget.classList.remove("is-active");
    window.localStorage.setItem("galleryViewMode", "grid");
  }

  list() {
    this.gridTarget.classList.add("is-list");
    this.listButtonTarget.classList.add("is-active");
    this.gridButtonTarget.classList.remove("is-active");
    window.localStorage.setItem("galleryViewMode", "list");
  }
}

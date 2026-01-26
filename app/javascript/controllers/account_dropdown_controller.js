import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
    }

    toggle(event) {
        event.stopPropagation()
        const isOpen = this.menuTarget.classList.contains("open")

        if (isOpen) {
            this.close()
        } else {
            this.open()
        }
    }

    open() {
        this.menuTarget.classList.add("open")
        document.addEventListener("click", this.closeOnClickOutside)
    }

    close() {
        this.menuTarget.classList.remove("open")
        document.removeEventListener("click", this.closeOnClickOutside)
    }

    closeOnClickOutside(event) {
        if (!this.element.contains(event.target)) {
            this.close()
        }
    }

    disconnect() {
        document.removeEventListener("click", this.closeOnClickOutside)
    }
}
import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["grid", "gridInput"]

    connect() {
        this.gridData = JSON.parse(this.gridInputTarget.value)
    }

    toggleCell(event) {
        const td = event.currentTarget
        const row = Number.parseInt(td.dataset.row, 10)
        const col = Number.parseInt(td.dataset.col, 10)

        this.gridData[row][col] = !this.gridData[row][col]
        td.classList.toggle("alive")
        td.classList.toggle("dead")
    }

    submitForm() {
        this.gridInputTarget.value = JSON.stringify(this.gridData)
    }
}
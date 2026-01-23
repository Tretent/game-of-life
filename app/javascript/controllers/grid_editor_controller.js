import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["grid", "gridInput"]

    connect() {
        this.gridData = JSON.parse(this.gridInputTarget.value)
    }

    toggleCell(event) {
        const td = event.currentTarget
        const row = parseInt(td.dataset.row, 10)
        const col = parseInt(td.dataset.col, 10)

        this.gridData[row][col] = !this.gridData[row][col]

        if (this.gridData[row][col]) {
            td.classList.remove("dead")
            td.classList.add("alive")
        } else {
            td.classList.remove("alive")
            td.classList.add("dead")
        }
    }

    submitForm() {
        this.gridInputTarget.value = JSON.stringify(this.gridData)
    }
}
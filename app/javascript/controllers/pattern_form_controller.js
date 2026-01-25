import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["name", "file", "submit", "fileError"]

    connect() {
        this.updateSubmitState()
    }

    async validateFile() {
        this.clearFileError()

        const file = this.fileTarget.files[0]
        if (!file) {
            this.updateSubmitState()
            return
        }

        try {
            const content = await file.text()
            const error = this.validatePatternContent(content)

            if (error) {
                this.showFileError(error)
                this.fileValid = false
            } else {
                this.fileValid = true
            }
        } catch (e) {
            this.showFileError("Could not read file")
            this.fileValid = false
            this.updateSubmitState()
        }

        this.updateSubmitState()
    }

    validatePatternContent(content) {
        const lines = content.trim().split("\n")

        if (lines.length < 3) {
            return "File must have at least 3 lines (header, dimensions, grid)"
        }

        // Validate generation header
        const headerMatch = lines[0].match(/^Generation\s+(\d+):$/)
        if (!headerMatch) {
            return "Invalid header format. Expected: Generation N:"
        }

        const generation = Number.parseInt(headerMatch[1], 10)
        if (generation < 1) {
            return "Generation must be at least 1"
        }
        if (generation >= 1000) {
            return "Generation must be less than 1000"
        }

        // Validate dimensions
        const dimMatch = lines[1].match(/^(\d+)\s+(\d+)$/)
        if (!dimMatch) {
            return "Invalid dimensions format. Expected: rows columns"
        }

        const rows = Number.parseInt(dimMatch[1], 10)
        const columns = Number.parseInt(dimMatch[2], 10)

        if (rows < 1) {
            return "Rows must be at least 1"
        }
        if (rows >= 100) {
            return "Rows must be less than 100"
        }
        if (columns < 1) {
            return "Columns must be at least 1"
        }
        if (columns >= 100) {
            return "Columns must be less than 100"
        }

        // Validate grid
        const gridLines = lines.slice(2)
        if (gridLines.length !== rows) {
            return `Expected ${rows} grid rows, got ${gridLines.length}`
        }

        for (let i = 0; i < gridLines.length; i++) {
            const line = gridLines[i]
            if (line.length !== columns) {
                return `Row ${i + 1} has ${line.length} columns, expected ${columns}`
            }
            if (!/^[.*]+$/.test(line)) {
                return `Row ${i + 1} contains invalid characters (only . and * allowed)`
            }
        }

        return null // Valid
    }

    updateSubmitState() {
        const nameValid = this.nameTarget.value.trim().length > 0
        const fileSelected = this.fileTarget.files.length > 0
        const fileValid = this.fileValid === true

        this.submitTarget.disabled = !(nameValid && fileSelected && fileValid)
    }

    showFileError(message) {
        this.fileErrorTarget.textContent = message
        this.fileErrorTarget.style.display = "block"
    }

    clearFileError() {
        this.fileErrorTarget.textContent = ""
        this.fileErrorTarget.style.display = "none"
        this.fileValid = false
    }

    loadExample() {
        const exampleContent = `Generation 1:
4 8
........
....*...
*****...
........`

        const file = new File([exampleContent], "example.txt", { type: "text/plain" })
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(file)
        this.fileTarget.files = dataTransfer.files

        this.validateFile()
    }
}

import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        nextFormId: String,
        resetFormId: String,
        maxGeneration: {type: Number, default: 1000}
    }

    static targets = ["playBtn", "pauseBtn", "nextBtn", "resetBtn"]

    connect() {
        this.intervalId = null
        this.updateButtonStates()
    }

    disconnect() {
        this.stopInterval()
    }

    play() {
        if (this.intervalId) return
        if (this.isAtMaxGeneration()) return

        this.next()
        this.intervalId = setInterval(() => this.next(), 1000)
        this.updateButtonStates()
    }

    pause() {
        this.stopAndUpdate()
    }

    next() {
        if (this.isAtMaxGeneration()) {
            this.stopAndUpdate()
            return
        }
        this.submitTurboForm(this.nextFormIdValue)
    }

    reset() {
        this.stopAndUpdate()
        this.submitTurboForm(this.resetFormIdValue)
    }

    stopAndUpdate() {
        this.stopInterval()
        this.updateButtonStates()
    }

    stopInterval() {
        if (this.intervalId) {
            clearInterval(this.intervalId)
            this.intervalId = null
        }
    }

    isPlaying() {
        return this.intervalId !== null
    }

    isAtMaxGeneration() {
        const generationElement = document.getElementById("generation_count")
        if (!generationElement) return false

        const currentGeneration = Number.parseInt(generationElement.textContent, 10)
        return currentGeneration >= this.maxGenerationValue
    }

    updateButtonStates() {
        const playing = this.isPlaying()

        // During auto-play: Play, Next, and Reset are disabled; only Pause is active
        // When paused/stopped: All controls except Pause are enabled
        this.playBtnTarget.disabled = playing
        this.pauseBtnTarget.disabled = !playing
        this.nextBtnTarget.disabled = playing
        this.resetBtnTarget.disabled = playing
    }

    submitTurboForm(formId) {
        const form = document.getElementById(formId)
        if (!form) return

        form.requestSubmit()

        requestAnimationFrame(() => {
            if (this.isAtMaxGeneration()) {
                this.stopAndUpdate()
            }
        })
    }
}

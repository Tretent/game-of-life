import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        nextUrl: String,
        resetUrl: String,
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
        this.stopInterval()
        this.updateButtonStates()
    }

    next() {
        if (this.isAtMaxGeneration()) {
            this.stopInterval()
            this.updateButtonStates()
            return
        }
        this.postRequest(this.nextUrlValue)
    }

    reset() {
        this.stopInterval()
        this.postRequest(this.resetUrlValue)
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

        const currentGeneration = parseInt(generationElement.textContent, 10)
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

    async postRequest(url) {
        const response = await fetch(url, {
            method: "POST",
            headers: {
                "Accept": "text/vnd.turbo-stream.html",
                "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
            }
        })

        if (response.ok) {
            const html = await response.text()
            Turbo.renderStreamMessage(html)

            // Check if we've reached the max generation after the DOM updates
            requestAnimationFrame(() => {
                if (this.isAtMaxGeneration()) {
                    this.stopInterval()
                    this.updateButtonStates()
                }
            })
        }
    }
}

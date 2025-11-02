class DDNetLogStreamer {
	constructor(apiBackend, apiToken, targetDiv) {
		this.apiBackend = apiBackend
		this.apiToken = apiToken
		this.targetDiv = targetDiv

		// total amount of log lines communicated by the backend
		this.max = 0

		// key is the logline number
		// and value is the line as a string
		this.lines = {}
	}

	onData(data) {
		let lineNum = data.offset
		let lineDivs = ''
		data.lines.forEach((line) => {
			if(this.lines[lineNum]) {
				console.log(`drop known line ${lineNum} we already have there: ${this.lines[lineNum]}`)
				// already got this line
				return
			}
			this.lines[lineNum] = line
			console.log(`NEW LOG LINE ${lineNum}`)
			lineDivs += `<div data-line-num="${lineNum}">${lineNum}: ${line}</div>`
			lineNum++
		})
		if(lineDivs) {
			this.targetDiv.insertAdjacentHTML('beforeend', lineDivs)
		}
		this.max = data.max
	}

	getLogs(offset, num) {
		const url = `${this.apiBackend}/log?token=${this.apiToken}&offset=${offset}&num=${num}`
		fetch(url)
			.then((res) => res.json())
			.then((data) => this.onData(data))
	}

	tail() {
		if (this.max === 0) {
			this.getLogs(0, 1)
			return
		}
		this.getLogs(this.max - 10, 10)
	}
}

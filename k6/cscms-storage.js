import http from "k6/http"
import { sleep } from "k6"

export let options = {
	vus: 1,
	duration: "1s"
}

export default function () {
	const start = Date.now()
	const res = http.get("https://storage.cscms.me/wmr5hp")
	const end = Date.now()
	console.info(`${end - start}ms`)
	sleep(1)
}

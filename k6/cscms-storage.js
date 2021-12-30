import http from "k6/http"
import { sleep } from "k6"

export let options = {
	vus: 5,
	duration: "10s"
}

export default function () {
	const res = http.get("https://storage.cscms.me/wmr5hp")
	check(res, {
		"is status 200": (r) => r.status === 200
	})
	sleep(1)
}

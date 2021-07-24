import http from 'k6/http'
import { sleep } from 'k6'

export let options = {
	stages: [
		{ duration: '30s', target: 100 },
		{ duration: '30s', target: 200 },
		{ duration: '3m', target: 200 },
		{ duration: '60s', target: 0 },
	],
}

export default function () {
	http.get('https://timetable-test.cscms.me')
	sleep(1)
}

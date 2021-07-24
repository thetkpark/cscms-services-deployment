import http from 'k6/http'
import { sleep, check, group } from 'k6'

export let options = {
	stages: [
		{ duration: '30s', target: 100 },
		{ duration: '30s', target: 200 },
		{ duration: '1m', target: 200 },
		{ duration: '60s', target: 0 },
	],
}

export default function () {
	// group('visit frontend', function () {
	// 	http.get('https://aka-test.cscms.me/')
	// 	sleep(1)
	// })

	group('create new shorten url', function () {
		http.post('https://aka-test.cscms.me/api/newUrl', {
			url: 'https://loadTestingUrlThatNoOneGonnaUse.com',
		})
	})
}

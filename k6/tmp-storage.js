import http from 'k6/http'
import { sleep } from 'k6'
import { FormData } from 'https://jslib.k6.io/formdata/0.0.2/index.js'

const testFile = open('./testFile', 'b')

export let options = {
	vus: 1,
	duration: '10s',
}

export default function () {
	const formData = new FormData()
	formData.append('file', http.file(testFile, 'testFile'))
	const res = http.post('https://tmp-test.cscms.me/api/file', formData.body(), {
		headers: { 'Content-Type': 'multipart/form-data; boundary=' + formData.boundary },
	})
	console.log(res.body)
	check(res, {
		'is status 201': r => r.status === 201,
	})
	sleep(1)
}

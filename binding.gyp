{
	"targets": [
		{
			"target_name": "xcorr",
			"sources": [ "lib/xcorr.cc" ],
			"link_settings": {
				"libraries": [ "-L/usr/src/app/parallella-fft-xcorr", "-lfft-demo-coprthr"]
			}
		}
	]
}

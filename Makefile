all: .virtualenv requirements.txt

requirements.txt: .virtualenv
	. .virtualenv/bin/activate; pip3 freeze > requirements.txt

howthiswasbuilt: .virtualenv buildozer.spec
	. .virtualenv/bin/activate ; pip3 install --upgrade buildozer
	. .virtualenv/bin/activate ; pip3 install --upgrade cython==0.21

.virtualenv:
	virtualenv .virtualenv

buildozer.spec:
	buildozer init

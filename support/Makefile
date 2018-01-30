all: amber app ../README.md

readme_SOURCES=$(shell find -maxdepth 1 -type f)

amber:
	git clone https://github.com/amberframework/amber
	cd amber && crystal deps

app: amber
	amber/bin/amber new app
	#cd app && crystal deps

../README.md: $(readme_SOURCES)
	perl tpl2md.pl

all: amber app ../README.md

amber:
	git clone https://github.com/amberframework/amber
	cd amber && shards

app: amber
	amber/bin/amber new app
	cd app && shards

../README.md: $(readme_SOURCES)
	perl tpl2md.pl

readme_SOURCES=$(shell find -maxdepth 1 -type f)

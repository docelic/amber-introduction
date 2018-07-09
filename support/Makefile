all: amber app diffs ../README.md

readme_SOURCES=$(shell find -maxdepth 1 -type f)

amber:
	git clone https://github.com/amberframework/amber
	cd amber && shards
	cd amber && make

app: amber
	amber/bin/amber new app
	cd app && shards

.PHONY: diffs
diffs:
	bash run-diffs.bash

../README.md: $(readme_SOURCES)
	perl tpl2md.pl

clean:
	rm -rf amber app

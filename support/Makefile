all: ../README.md

readme_SOURCES=$(shell find -maxdepth 1 -type f)

../README.md: $(readme_SOURCES)
	@perl tpl2md.pl

app:
	amber/bin/amber new app

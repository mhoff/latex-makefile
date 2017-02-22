### Configurables ###
ROOT_BASENAME = sample
TARGET_PDF = ${ROOT_BASENAME}.pdf
BUILD_DIR = .build
SOURCE_DIRS =

### Internal ###
ROOT_FILENAME = ${ROOT_BASENAME}.tex
PDFLATEX = pdflatex -interaction=nonstopmode
LATEXMK = latexmk -bibtex -pdf -pdflatex="yes '' | ${PDFLATEX}" -use-make -outdir=${BUILD_DIR}

.PHONY: all
all: show

.PHONY: show
show: compile
ifneq (, $(shell which xdg-open))
	xdg-open ${BUILD_DIR}/${ROOT_BASENAME}.pdf
else ifneq (, $(shell which evince))
	evince ${BUILD_DIR}/${ROOT_BASENAME}.pdf &> /dev/null &
else
	$(error No suitable application for opening PDFs registered.)
endif

.PHONY: pdf
pdf: compile
	cp ${BUILD_DIR}/${ROOT_BASENAME}.pdf ${TARGET_PDF}

compile:
ifdef SOURCE_DIR
	for SOURCE_DIR in "${SOURCE_DIRS[@]}"; do
		find ${SOURCE_DIR} -type d -exec mkdir -p ${BUILD_DIR}/{} \;
	done
endif
	${LATEXMK} ${ROOT_FILENAME}

%.pdf: %.svg
ifneq (, $(shell which rsvg-convert))
	rsvg-convert -f pdf -o $@ $<
else
	$(warning Tool 'rsvg-convert' is not installed. Converted vector graphics could be of poor quality.)
ifneq (, $(shell which cairosvg))
	cairosvg $< -o $@
else ifneq (, $(shell which inkscape))
	inkscape $< --export-pdf=$@
else
	convert $< $@
endif
endif
	pdfcrop $@ $@

wc:	compile
	pdftops ${BUILD_DIR}/${ROOT_BASENAME}.pdf
	ps2ascii ${BUILD_DIR}/${ROOT_BASENAME}.ps > ${BUILD_DIR}/${ROOT_BASENAME}.txt
	wc -w ${BUILD_DIR}/${ROOT_BASENAME}.txt
	rm ${BUILD_DIR}/${ROOT_BASENAME}.ps ${BUILD_DIR}/${ROOT_BASENAME}.txt

.PHONY: clean
clean:
	rm -Rfv ${TARGET_BASENAME}.pdf ${BUILD_DIR}

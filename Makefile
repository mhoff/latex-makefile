### Configurables ###
ROOT_BASENAME = sample
TARGET_PDF = ${ROOT_BASENAME}.pdf
BUILD_DIR = .build
SOURCE_DIRS =
BIB_RESOURCES = $(filter-out ${TARGET_BIB}, $(wildcard *.bib))
BIBER_CONF = .statics/biber.conf

### Internal ###
ROOT_FILENAME = ${ROOT_BASENAME}.tex
TARGET_BIB = ${BUILD_DIR}/${ROOT_BASENAME}.bib
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

compile: ${TARGET_BIB}
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

$(TARGET_BIB): $(BIB_RESOURCES) ${BIBER_CONF}
	mkdir -p ${BUILD_DIR}
	rm -f $@
	$(foreach bib_file, $(BIB_RESOURCES), cat $(bib_file) >> $@;)
ifneq (, $(shell which biber))
	biber --tool --output_file $@~ $@
	mv $@~ $@
else
	$(warning Tool 'biber' is not installed. Formatting issues could arise in bibliography.)
endif

wc:	compile
	pdftops ${BUILD_DIR}/${ROOT_BASENAME}.pdf
	ps2ascii ${BUILD_DIR}/${ROOT_BASENAME}.ps > ${BUILD_DIR}/${ROOT_BASENAME}.txt
	wc -w ${BUILD_DIR}/${ROOT_BASENAME}.txt
	rm ${BUILD_DIR}/${ROOT_BASENAME}.ps ${BUILD_DIR}/${ROOT_BASENAME}.txt

.PHONY: clean
clean:
	rm -Rfv ${TARGET_BASENAME}.pdf ${BUILD_DIR}

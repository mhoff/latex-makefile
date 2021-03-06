# latexmk-makefile

This repository provides a `make` configuration for clean handling of LaTeX projects.

```
$ tree .
.
├── dirty.bib
├── fig
│   └── circle.svg
├── Makefile
├── README.md
└── sample.tex
$ make pdf
[...]
$ tree .
.
├── dirty.bib
├── fig
│   └── circle.svg
├── Makefile
├── README.md
├── sample.pdf # generated PDF
└── sample.tex
$ tree .build
.build/
├── fig
│   └── circle.pdf # generated by \includegraphics{fig/circle}
├── sample.aux
├── sample.bbl
├── sample.bib # generated merging all *.bib and correcting mistakes with biber
├── sample.bib.blg
├── sample.blg
├── sample.fdb_latexmk
├── sample.fls
├── sample.log
└── sample.pdf
$ make show # displays hidden PDF: .build/sample.pdf
$ make clean # simply deletes .build
```

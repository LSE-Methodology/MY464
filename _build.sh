#!/bin/sh

cp ./images/* .
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

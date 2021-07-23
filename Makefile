bash:
	docker build -t kishiyamat/interspeech-2021-replication .
	docker run -it --rm kishiyamat/interspeech-2021-replication bash
check:
	cd test/; Rscript test.R
exp1:
	cd note; Rscript -e 'library(rmarkdown); rmarkdown::render("./experiment-1.Rmd")'
exp2:
	cd note; Rscript -e 'library(rmarkdown); rmarkdown::render("./experiment-2.Rmd")'

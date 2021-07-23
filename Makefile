bash:
	docker build -t kishiyamat/interspeech-2021-replication .
	docker run -it --rm kishiyamat/interspeech-2021-replication bash
check:
	cd test/; Rscript test.R
hypara:
	cd src; python hyparams.py
exp1:
	cd src; python run.py 1
exp2:
	cd src; python run.py 2
results:
	cd src; Rscript -e 'library(rmarkdown); rmarkdown::render("./results.Rmd")'
	cd src; rm results.md

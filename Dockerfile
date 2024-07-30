FROM inwt/r-batch:4.1.2

ADD . .

RUN installPackage

CMD ["Rscript", "inst/RScripts/exec_main.R"]

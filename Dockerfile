FROM inwt/r-batch:4.4.3

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libsasl2-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

ADD . .

RUN installPackage

CMD ["Rscript", "inst/RScripts/exec_main.R"]

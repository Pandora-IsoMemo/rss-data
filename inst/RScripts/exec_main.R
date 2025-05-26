# 00 Preparation ---------------------------------------------------------------
cat("System information:\n")
for (i in seq_along(sysinfo <- Sys.info()))
cat(" ", names(sysinfo)[i], ":", sysinfo[i], "\n")
options(warn = 2)

library(rssData)
library(methods)
sessionInfo()

# 01 Start RSS Collector -------------------------------------------------------
status <- main()

check_source_availability()

q(save = "no", status = status)

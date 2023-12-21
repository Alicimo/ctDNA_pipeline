#!/usr/bin/env Rscript

library(data.table)
source("/home/martin06/src/ichorCNA.wrapper.R")

fnames <- list.files("QDNA/bin.1000/CNs/",full.names=T)
if(length(fnames)==0) stop("No QDNA files found; check you are running this in the base project dir")

env.vars <- get.default.env.vars.ichorCNA()
base.dir <- "./ichor/"

x <- rbindlist(lapply(fnames,function(fname){
    data <- fread(fname,header=T)
    noise <- data[,diff(unlist(.SD[,4,with=F])),.(chromosome)][,median(abs(V1))]
    ichor.default <- run.ichor.pipeline(data, env.vars, paste0(base.dir,"ichor.default/"))
    y <- ichor.default$summary
    y$noise <- noise
    return(y)
}))

x[,Sample.name:=gsub(".sorted.dedupped","",Sample.name)]
x <- x[order(Sample.name)]

fwrite(x,"ichor.summary.csv")


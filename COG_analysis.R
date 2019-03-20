suppressPackageStartupMessages({
  library(optparse)
})

option_list = list(
  make_option(c("-I", "--input"), type="character", default="./",
              help="Input file", metavar="character"),
  make_option(c("-O", "--out"), type="character", default="COG_results.pdf", 
              help="output image name; [default= %default]", metavar="character"),
  make_option(c("-T", "--top"), type="integer", default=20,
              help="Cutoff for number of top hits; [default=%default]", metavar="character")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

print("USAGE: $ COG_analysis.R -I input_file -O save.filename -T Top hits cutoff (default 20)")

# check for necessary specs
if (is.null(opt$input)) {
  print ("WARNING: No working input file specified with '-I' flag.")
  stop()
} else {  cat ("Working infile is ", opt$input, "\n")
  wd_location <- opt$input  
#  setwd(wd_location)
}

cat ("Results will be saved as ", opt$out, "\n")
save_filename <- opt$out

# libraries
library(ggplot2)
library(data.table)

# importing the file
data_table = read.table(file=wd_location, sep="\t")
foo = data.frame(do.call('rbind', strsplit(as.character(data_table$V3), '|', fixed = TRUE)))
cat_table = cbind(data_table, foo)
cat_table[,c("V3", "X1")] = NULL
merged = aggregate(cat_table$V1, by=list(Category=cat_table$X2), FUN=sum)
l1_table = data.table(merged)
colnames(l1_table) = c("Category", "Average")
l1_table <- l1_table[order(-l1_table$Average)]

# graphing
CbPalette <- c("#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c",
   "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#ffff99", "#b15928", "#8dd3c7",
   "#ffffb3",  "#bebada",  "#fb8072",  "#80b1d3",  "#fdb462",  "#b3de69",
   "#fccde5",  "#d9d9d9",  "#bc80bd",  "#ccebc5",  "#ffed6f", "#e41a1c",
   "#377eb8", "#4daf4a",  "#984ea3",  "#ff7f00", "#ffff33",  "#a65628",
   "#f781bf", "#999999", "#000000", "#a6cee4", "#1f78b5", "#b2df8b")

# sanity check
if (opt$top > nrow(l1_table)) {
  opt$top = nrow(l1_table)
}

# dealing with manual color scale
if (opt$top < 38) {
  bp<- ggplot(l1_table[c(0:opt$top),], aes(x="", y=Average, fill=Category)) +
    geom_bar(width = 1, stat = "identity") +
    scale_fill_manual(values = CbPalette)
} else {
  bp<- ggplot(l1_table[c(0:opt$top),], aes(x="", y=Average, fill=Category)) +
    geom_bar(width = 1, stat = "identity")
}
pie <- bp + coord_polar("y", start=0) +
  theme(axis.text=element_blank(), legend.position = "right" )

cat ("\nSuccess!\nSaving COG pie chart as ", save_filename, " now.\n")
pdf(file = save_filename, width=10, height=7)
pie
dev.off()



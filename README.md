
# Multi-omic Set Enrichment Analysis

## Introduction
Though there are many algorithms for enrichment analysis, most do not perform 
permutation statistics which do not rely on assumptions about the input 
distribution and do not allow for analysis of multiple omics data types. 
This tool enables users to input any omics data type as long as they provide 
corresponding set annotations or use the default gene set annotations. Users 
can also use this tool to prioritize drug mechanisms of action based on 
selective toxicity using drug mechanism enrichment analysis 
(https://belindabgarana.github.io/DMEA) as long as they provide expression 
data which corresponds to the input omics data type or use the default CCLE 
RNA-seq data (version 19Q4) and PRISM drug screen of 327 adherent cancer cell 
lines.

## Citation

To cite this package, please use:
Garana, B.B., Joly, J.H., Delfarah, A. et al. Drug mechanism enrichment analysis improves prioritization of therapeutics for repurposing. BMC Bioinformatics 24, 215 (2023). https://doi.org/10.1186/s12859-023-05343-8

## Installation
To install this package directly from GitHub, start R and enter:

``` r
if (!require("devtools", quietly = TRUE))
  install.packages("devtools")
  
devtools::install_github("BelindaBGarana/panSEA")
```

If you are using Windows OS, you may need to change the above code to:

``` r
if (!require("devtools", quietly = TRUE))
  install.packages("devtools")
  
devtools::install_github("BelindaBGarana/panSEA", build = FALSE)
```
## Case 1: 2 Groups (e.g., Diseased vs. Healthy)

If you input data from 2 groups (e.g., diseased vs. healthy), the panSEA 
function will run differential expression analysis using limma::eBayes 
followed by ssGSEA (e.g., using the resulting gene Log2FC values) and DMEA 
for each input type. If you provide a list of different input types, then this 
analysis will be run for each element in the input list separately before being 
compiled and visualized with tile plots and network graphs.

Example:
1. Prepare list of input expression data frames
In this case, we will prepare 3 different NULL data sets using randomized 
normal distributions
```{r}
# create list of gene symbols
Gene <- paste0("Gene_", seq(from = 1, to = 50))

# prepare expression data for samples
Sample_1 <- rnorm(length(Gene), sd = 0.5)
Sample_2 <- rnorm(length(Gene), sd = 0.5)
Sample_3 <- rnorm(length(Gene), sd = 0.5)
Sample_4 <- rnorm(length(Gene), sd = 0.5)
Sample_5 <- rnorm(length(Gene), sd = 0.5)
Sample_6 <- rnorm(length(Gene), sd = 0.5)

# feature names (e.g., gene symbols) should be row names and 
# column names should be sample names
expr <- data.frame(Gene, Sample_1, Sample_2, Sample_3, 
  Sample_4, Sample_5, Sample_6)

expr2 <- data.frame(Gene, Sample_1, Sample_2, Sample_3, 
  Sample_4, Sample_5, Sample_6)

# combine inputs as a list of data frames
types <- c("Transcriptomics", "Proteomics")
data <- list(expr, expr2)
```

2. Prepare gene set info
If you are processing different omics types, you may need different set 
annotation information (i.e., gmt objects) for each omics type
```{r}
# create data frame for gene set info
info <- as.data.frame(Gene)

# create column containing gene set annotations
info$gs_name <- rep(paste("Set", LETTERS[seq(from = 1, to = 5)]), 10)

# convert data frame into gmt object
gmt.features <- DMEA::as_gmt(info, element.names = "Gene", set.names = "gs_name")

# create list so that each input data frame has a corresponding gmt object
# in this example, both input data frames will use the same gmt for gene sets
gmt.features <- as.list(rep(gmt.features, length(types)))
```

3. Prepare drug set info
```{r}
# create list of drug names
Drug <- paste0("Drug_", seq(from = 1, to = 24))

# create data frame for drug set info
# Drug is our default name for the column containing drug names
drug.info <- as.data.frame(Drug)

# moa is our default name for the column containing drug set annotations
drug.info$moa <- rep(paste("Set", LETTERS[seq(from = 1, to = 4)]), 6)

# convert data frame into gmt object
gmt.drugs <- DMEA::as_gmt(drug.info)
```

4. Prepare drug sensitivity data frame
```{r}
# create list of sample names
CCLE_ID <- seq(from = 1, to = 21)

drug.sensitivity <- as.data.frame(CCLE_ID)

# create list of drug names
Drug <- paste0("Drug_", seq(from = 1, to = 24))

# give each drug values representative of AUC sensitivity scores
for(i in 1:length(Drug)){
  drug.sensitivity[ , Drug[i]] <- rnorm(length(CCLE_ID),
                                        mean = 0.83, sd = 0.166)
}
```

5. Prepare expression data frames
```{r}
# by default, column 1 of your expression data frame is
# the column name from which sample names are gathered and
# the column containing sample names in your drug sensitivity
# data frame should have the same name
expr <- as.data.frame(CCLE_ID)
expr2 <- as.data.frame(CCLE_ID)

# give each gene values representative of normalized expression
# each gene is represented by a column in your expression data frame
for(i in 1:length(Gene)){
  expr[ , Gene[i]] <- rnorm(length(CCLE_ID), sd = 0.5)
  expr2[ , Gene[i]] <- rnorm(length(CCLE_ID), sd = 0.5)
}

# create list so that each input data frame has a corresponding 
# expression data frame
expression <- list(expr, expr2)
```

6. Run panSEA and examine enrichment results visually
If you were using real transcriptomic data, you could use the default 
gmt.genes or adjust it to query the MSigDB; you could also use the default 
gmt.drugs, drug.sensitivity, and expression to query adherent CCLE RNA-seq data 
(version 19Q4) and the PRISM drug screen
```{r}
panSEA.2groups <- panSEA::panSEA(data, types, gmt.features = gmt.features, 
                                 gmt.drugs = gmt.drugs, 
                                 drug.sensitivity = drug.sensitivity, 
                                 expression = expression)
```

## Case 2: 1 Group (e.g., Diseased)
If you input data from 1 group (e.g., diseased), the panSEA function will run 
ssGSEA and DMEA for each column of each input type. If you provide a list of 
different input types, then this analysis will be run for each element in the 
input list separately before being compiled and visualized with tile plots and 
network graphs. In this case, the outputs will be a list of these multi-omic 
analyses for each column (e.g., sample) in the input data types.

Example:
1. Prepare list of input data frames
In this example, we will use differential expression from transcriptomic data 
sets for sensitivity vs. resistance to EGFR or RAF inhibitors. However, 
different omics data types could also be used and have multiple columns
```{r}
types <- c("GSE66539_SKCM_sensitive_vs_resistant_to_vemurafenib",
"GSE31625_NSCLC_sensitive_vs_resistant_to_erlotinib")

data.list <- list()
for (i in 1:length(types)) {
data.list[[types[i]]] <- read.csv(
paste0("https://raw.githubusercontent.com/BelindaBGarana/", 
"DMEA/shiny-app/Examples/Gene_signature/", types[i], 
"/Filtered_gene_signature_no_duplicates.csv"))
}
```

2. Run panSEA and examine enrichment results visually
```{r}
panSEA.1group <- panSEA::panSEA(data.list, types, 
group.names = "Sensitive_vs_resistant_to_EGFRi", group.samples = list(2))

# visualize enrichment of gene sets (dot plot)
panSEA.1group$mGSEA.results[["Log2FC"]]$compiled.results$dot.plot

# visualize enrichment of drug sets (dot plot)
panSEA.1group$mDMEA.results[["Log2FC"]]$compiled.results$dot.plot

# visualize connectivity of leading edge genes (network graph)
panSEA.1group$mGSEA.network[["Log2FC"]]$interactive

# visualize connectivity of leading edge drugs (network graph)
panSEA.1group$mDMEA.network[["Log2FC"]]$interactive
```
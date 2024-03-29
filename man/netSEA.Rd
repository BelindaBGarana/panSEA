\name{netSEA}

\alias{netSEA}

\title{Network Graph
}

\description{Generate network graph of leading edge elements 
from top significant enrichments
}

\usage{
netSEA(inputs, outputs, element.names = rep("Gene", length(inputs)), 
rank.var = rep("Log2FC", length(inputs)), p = 0.05, FDR = 0.25,
n.network.sets = 2*length(inputs), scale = 5)
}

\arguments{
  \item{inputs}{List of data frames containing inputs used for 
  enrichment analyses. Each data frame must have column names matching the 
  element.name and rank.var given in the same order (e.g., if "Gene" and 
  "Log2FC" are the first element.name and rank.var, respectively, the first 
  data frame in the inputs list must contain columns with matching names).
  }

  \item{outputs}{List of data frames containing outputs from enrichment 
  analyses. Each data frame in the list must have columns "NES", "p-value", 
  "FDR_q_value", and "Leading_edge".
  }

  \item{element.names}{Vector of column names containing element names (e.g., 
  gene symbols) in each corresponding data frame in the inputs list. Default: 
  rep("Gene", length(inputs)).
  }

  \item{rank.var}{Vector of column names containing rank variable (e.g., 
  Log2FC) in each corresponding data frame in the inputs list. Default: 
  rep("Log2FC", length(inputs)).
  }
  
  \item{p}{P-value cut-off for significant enrichments. Default: 0.05.
  }

  \item{FDR}{False discovery rate cut-off value for significant enrichments. 
  Default: 0.25.
  }
  
  \item{n.network.sets}{Number of sets from enrichment analyses to be 
  represented in the network graph. The top significant sets will be selected 
  based on abs(NES) and p & FDR cutoff values. Default: 2*length(inputs).
  }
  
  \item{scale}{Numeric value to multiply by rank.var value to size vertices on 
  network graph for visibility. Default: 5.
  }
}

\value{
  \item{static}{Static network graph of leading edge features from top 
  significantly enriched sets. If 
  length(group.names) == 1, list of outputs corresponds to each sample (i.e., 
  column name in each data frame in the input data.list)}
  
  \item{interactive}{Interactive network graph of leading edge features from top 
  significantly enriched sets. If 
  length(group.names) == 1, list of outputs corresponds to each sample (i.e., 
  column name in each data frame in the input data.list)}
}

\author{Belinda B. Garana
}

\note{To save static output, generate plot and then use dev.print. 
To save interactive output as HTML file, use visNetwork::visSave.
}

\seealso{
  \link[panSEA]{mGSEA}
  \link[panSEA]{mDMEA}
  \link[panSEA]{panSEA}
}

\examples{
### Step 1: Run mGSEA (or mDMEA)
## Step 1a: prepare gene weight data frames
# create list of gene symbols
Gene <- paste0("Gene_", seq(from = 1, to = 50))

# by default, gene symbols are found in
# the first column of your weights data frame
weights <- as.data.frame(Gene)
weights2 <- as.data.frame(Gene)

# give each gene a weight
# by default, gene weight values are found in
# the second column of your weights data frame
weights$Log2FC <- rnorm(length(Gene))
weights2$Log2FC <- rnorm(length(Gene))

## Step 1b: prepare set info data frame
# alternatively, a gmt object could be provided
info <- as.data.frame(Gene)

# create column containing gene set annotations
info$gs_name <- rep(paste("Set", LETTERS[seq(from = 1, to = 5)]), 10)

## Step 1c: perform mGSEA and store results
data.list <- list(weights, weights2)
gmt <- DMEA::as_gmt(info, element.names = "Gene", set.names = "gs_name")
gmt.list <- list(gmt, gmt)
types <- c("Transcriptomics", "Proteomics")
mGSEA.test <- panSEA::mGSEA(data.list, gmt.list, types)

### Step 2: Extract results
outputs <- list()
for (i in 1:length(types)) {
  outputs[[types[i]]] <- mGSEA.test$all.results[[types[i]]]$result
}

### Step 3: Create network graph
mGSEA.network <- panSEA::netSEA(data.list, outputs)
}

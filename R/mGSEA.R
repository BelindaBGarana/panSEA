mGSEA <- function(data, gmt=as.list(rep("msigdb_Homo sapiens_C2_CP:KEGG", 
                                        length(types))), 
                  types, feature.names=rep("Gene", length(types)), 
                  rank.var=rep("Log2FC", length(types)), 
                  direction.adjust=NULL, p=0.05, FDR=0.25, 
                  num.permutations=1000, stat.type="Weighted", min.per.set=6, 
                  n.dot.sets = 10){
  #### Step 1. Perform ssGSEA on each omics type ####
  ssGSEA.list <- list()
  for(i in 1:length(types)) {
    message(paste("Running ssGSEA using", types[i], "data"))
    
    ssGSEA.list[[types[i]]] <- ssGSEA(data[[i]], 
                                    gmt[[i]], feature.names[i], rank.var[i], 
                                    direction.adjust, FDR,
                                    num.permutations, stat.type, min.per.set,
                                    sep, exclusions, descriptions)
  }

  #### Step 2. Compile ssGSEA results across omics types ####
  compiled.GSEA <- compile_mGSEA(ssGSEA.list, p, FDR, n.dot.sets)
  
  return(list(compiled.results = compiled.GSEA, 
              all.results = ssGSEA.list
  ))
}
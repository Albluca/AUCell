# Help files will be automatically generated from the coments starting with #'
# (https://cran.r-project.org/web/packages/roxygen2/vignettes/rd.html)
# @import data.table
#'
#' @title AUCell.exploreThresholds
#' @description Plots all the AUC histograms (per gene-set) and calculates several likely thresholds for each gene-set
#' @param aucMatrix AUC matrix returned by \code{\link{AUCell.calcAUC}}.
#' @param seed Random seed, for reproducibility of random computations.
#' @param thrP Probability to determine outliers in some of the distributions (see 'details' section).
#'
#' By default it is set to 1\% (thrP): if there are 3000 cells in the dataset, it is expected that approximately 30 cells are over this threshold if the AUC is normally distributed.
#' @param nCores Number of cores to use for computation.
#' @param plotHist Whether to plot the AUC histograms. (TRUE / FALSE)
#' @param densAdjust Parameter for the density curve. (See ?density for details).
#' @param assignCells Return the list of cells that pass the automatically selected threshold? (TRUE/FALSE)
#' @param nBreaks Number of bars to plot in the histograms.
#' @param verbose Should the function show progress messages? (TRUE / FALSE)
#' @return List with the following elements for each gene-set:
#' \itemize{
#' \item 'aucThr' Thresholds calculated with each method (see 'details' section), and the number of cells that would be assigned using that threshold.
#'
#' If assignCells=TRUE, the threshold selected automatically is the highest value (in most cases, excluding the global distribution).
#' \item 'seed' Seed provided as argument
#' \item 'assignment' List of cells that pass the selected AUC threshold (if \code{assignCells=TRUE})
#' }
#' If \code{plotHist=TRUE} the AUC histogram is also plot,
#' including the distributions calculated and the corresponding thresholds in the same color (dashed vertical lines).
#' The threshold that is automatically selected is shown as a thicker non-dashed vertical line.
#'
#' @details To ease the selection of an assignment theshold, this function adjusts the AUCs of each gene-set to several distributions and calculates possible thresholds:
#' \itemize{
#' \item \code{minimumDens} (plot in Blue): Inflection point of the density curve. This is usually a good option for the ideal situation with bimodal distributions.
#'
#' To avoid false positives, by default this threshold will not be chosen if the second distribution is higher (i.e. the majority of cells have the gene-set "active").
#' \item \code{L_k2} (plot in Red): Left distribution, after adjusting the AUC to a mixture of two distributions. The threshold is set to the right (prob: \code{1-(thrP/nCells)}). Only available if 'mixtools' package is installed.
#' \item \code{R_k3} (plot in Pink): Right distribution, after adjusting the AUC to a mixture of three distributions. The threshold is set to the left (prob: \code{thrP}). Only available if 'mixtools' package is installed.
#' \item \code{Global_k1} (plot in Grey): "global" distribution (i.e. mean and standard deviations of all cells). The threshold is set to the right (prob: \code{1-(thrP/nCells)}).
#'
#' The threshold based on the global distribution is ignored from the automatic selection unless the mixed models are overlapping.
#' }
#' Note: If \code{assignCells=TRUE}, the highest threshold is used to select cells.
#' However, keep in mind that this function is only meant to ease the selection of the threshold, and we highly recommend to look at the AUC histograms and adjust the threshold manually if needed.
#' We recommend to be specially aware on gene-sets with few genes (10-15) and thresholds that are set extremely low.
#'
#' @seealso Previous step in the workflow: \code{\link{AUCell.calcAUC}}.
#'
#' See the package vignette for examples and more details: \code{vignette("AUCell")}
#' @example inst/examples/example_AUCell.exploreThresholds.R
#' @export


# Runs .auc.assignmnetThreshold on each gene set (AUC)
AUCell.exploreThresholds <- function(aucMatrix, seed=987, thrP=0.01, nCores=1, plotHist=TRUE, densAdjust=2, assignCells=FALSE, nBreaks=100, verbose=TRUE) # nDist=NULL,
{
  suppressPackageStartupMessages(library(data.table)) # NEW
  if(nCores > 1 && plotHist) {
    nCores <- 1
    warning("Cannot plot in paralell")
  }

  if(nCores==1)
  {
    assigment <- lapply(colnames(aucMatrix), function(gSetName)
    {
      auc <- aucMatrix[,gSetName]
      aucThr <- .auc.assignmnetThreshold(auc, thrP=thrP, seed=seed, plotHist=plotHist, gSetName=gSetName, densAdjust=densAdjust, nBreaks=nBreaks)
      assignedCells <- NULL
      if(!is.null(aucThr)) assignedCells <- names(auc)[which(auc>aucThr$selected)]

      list(aucThr=aucThr, seed=seed, assignment=assignedCells)

    })
    names(assigment) <- colnames(aucMatrix)

  }else
  {
    # Run each geneSet in parallel
    suppressMessages(require("doMC", quietly=TRUE)); require("doRNG", quietly=TRUE)
    registerDoMC(nCores)
    if(verbose) message(paste("Using", getDoParWorkers(), "cores."))

    assigment <- foreach(gSetName=colnames(aucMatrix)) %dorng%
    {
      auc <- aucMatrix[,gSetName]
      aucThr <- .auc.assignmnetThreshold(auc, thrP=thrP, seed=seed, plotHist=plotHist, gSetName=gSetName, nBreaks=nBreaks)
      assignedCells <- NULL
      if(!is.null(aucThr)) assignedCells <- names(auc)[which(auc>aucThr$selected)]

      tmp <- list(aucThr=aucThr, seed=seed, assignment=assignedCells)
      return(setNames(list(tmp), gSetName))
    }
    attr(assigment, "rng") <- NULL
    assigment <- unlist(assigment, recursive = FALSE)[colnames(aucMatrix)]
  }
  # If cell assignment is not requested, remove from the output (it was initially calculated to know the number of cells)
  if(!assignCells) assigment <- lapply(assigment, function(x) x[which(!names(x) %in% "assignment")])

  assigment
}



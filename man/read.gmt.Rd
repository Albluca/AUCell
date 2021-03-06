% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aux_read.gmt.R
\name{read.gmt}
\alias{read.gmt}
\alias{write.gmt}
\alias{write.gmt.single}
\title{Functions to manipulate GMT files (gene-set format)}
\usage{
read.gmt(fileName)

write.gmt(geneSets, fileName = NULL, gmtDir = NULL)

write.gmt.single(genes, setName, fileName = NULL)
}
\arguments{
\item{fileName}{File name to read or write into}

\item{geneSets}{[write.gmt] List containing the gene-sets. The gene-sets should be provided as a 'named list' in which each element is a gene-set (i.e. \code{list(geneSet1=c("gene1", "gene2"))})}

\item{gmtDir}{[write.gmt] Directory, if diferent from \code{getwd()}}

\item{genes}{[write.gmt.single] Character vector containing the genes to write into the file}

\item{setName}{[write.gmt.single] Name of the gene set}
}
\value{
\code{read.gmt} returns a list of gene sets (the gene-set names as \code{names()}, and the elements of the gene-set as character vector).
}
\description{
read.gmt: Reads the gene-sets in a .gmt file.

write.gmt: Write several gene-sets into a single file (input: list).

write.gmt.single: Writes a gene set into a file (input: character vector).
}
\details{
File format: One gene-set per line, tab separated elements (i.e. genes). The first two elements of the line are the gene-set name (The second element can be replaced by a description of the gene set).

Example:

<geneSetName> <tab> <geneSetName> <tab> <tab-separated genes>
}
\examples{

# write.gmt.single (one gene set)
aGeneSet <- c("gene1", "gene2", "gene3")
write.gmt.single(aGeneSet, setName="geneSet1", fileName="aMiniGeneSet.gmt")


# write.gmt (multiple gene sets)
anotherGeneSet <- paste("gene", sample(1:100, 10), sep="")
geneSets <- list(geneSet1=aGeneSet,
                 geneSet2=anotherGeneSet)
geneSets
write.gmt(geneSets, fileName="bothGeneSets.gmt", gmtDir=".")


# read.gmt
read.gmt("bothGeneSets.gmt")
}


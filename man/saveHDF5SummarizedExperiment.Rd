\name{saveHDF5SummarizedExperiment}

\alias{saveHDF5SummarizedExperiment}
\alias{loadHDF5SummarizedExperiment}

\title{Save/load an HDF5-based SummarizedExperiment object}

\description{
  \code{saveHDF5SummarizedExperiment} and
  \code{loadHDF5SummarizedExperiment} can be used to save/load an HDF5-based
  \link[SummarizedExperiment]{SummarizedExperiment} object to/from disk.
}

\usage{
saveHDF5SummarizedExperiment(x, dir="my_h5_se", replace=FALSE,
                             chunkdim=NULL, level=NULL, verbose=FALSE)
loadHDF5SummarizedExperiment(dir="my_h5_se")
}

\arguments{
  \item{x}{
    A \link[SummarizedExperiment]{SummarizedExperiment} object.
  }
  \item{dir}{
    The path (as a single string) to the directory where to save the
    HDF5-based \link[SummarizedExperiment]{SummarizedExperiment} object
    or to load it from.
    When saving, the directory will be created so should not already exist,
    unless \code{replace} is set to \code{TRUE}.
  }
  \item{replace}{
    If directory \code{dir} already exists, should it be replaced with a
    new one? The content of the existing directory will be lost!
  }
  \item{chunkdim, level}{
    The dimensions of the chunks and the compression level to use for
    writing the assay data to disk.
    Passed to the internal calls to \code{writeHDF5Array}.
    See \code{?\link{writeHDF5Array}} for more information.
  }
  \item{verbose}{
    Set to \code{TRUE} to make the function display progress.
  }
}

\details{
  These functions use functionalities from the \pkg{SummarizedExperiment}
  package internally and so require this package to be installed.

  \code{saveHDF5SummarizedExperiment} creates the directory specified
  thru the \code{dir} argument and then populates it with the HDF5 datasets
  (one per assay in \code{x}) plus a serialized version of \code{x} that
  contains pointers to these datasets. This directory provides a
  self-contained HDF5-based representation of \code{x} that can then
  be loaded back in R with \code{loadHDF5SummarizedExperiment}.
  Note that this directory is \emph{relocatable} i.e. it can be moved
  (or copied) to a different place, on the same or a different computer,
  before calling \code{loadHDF5SummarizedExperiment} on it. For convenient
  sharing with collaborators, it is suggested to turn it into a tarball
  (with Unix command \code{tar}), or zip file, before the transfer.
  Please keep in mind that \code{saveHDF5SummarizedExperiment} and
  \code{loadHDF5SummarizedExperiment} don't know how to produce/read
  tarballs or zip files at the moment, so the process of packaging/extracting
  the tarball or zip file is entirely the user responsibility. It is
  typically done from outside R.

  Finally please note that, depending on the size of the data to write to
  disk and the performance of the disk, \code{saveHDF5SummarizedExperiment}
  can take a long time to complete. Use \code{verbose=TRUE} to see its
  progress.

  \code{loadHDF5SummarizedExperiment} is generally very fast, even if
  the assay data is big, because all the assays in the returned object
  are \link{HDF5Array} objects pointing to the on-disk HDF5 datasets
  located in \code{dir}. \link{HDF5Array} objects are typically
  light-weight in memory.
}

\value{
  \code{saveHDF5SummarizedExperiment} returns an invisible
  \link[SummarizedExperiment]{SummarizedExperiment} object where all
  the assays are \link{HDF5Array} objects pointing to the HDF5 datasets
  saved in \code{dir}. It's in fact the same obect as the object that
  would be returned by calling \code{loadHDF5SummarizedExperiment} on
  \code{dir}.
}

\author{Hervé Pagès}

\seealso{
  \itemize{
    \item \link[SummarizedExperiment]{SummarizedExperiment} and
          \link[SummarizedExperiment]{RangedSummarizedExperiment}
          objects in the \pkg{SummarizedExperiment} package.

    \item The \code{\link{writeHDF5Array}} function which
          \code{saveHDF5SummarizedExperiment} uses internally to write
          the assay data to disk.
  }
}

\examples{
library(SummarizedExperiment)
nrows <- 200; ncols <- 6
counts <- matrix(runif(nrows * ncols, 1, 1e4), nrows)
colData <- DataFrame(Treatment=rep(c("ChIP", "Input"), 3),
                     row.names=LETTERS[1:6])
se0 <- SummarizedExperiment(assays=SimpleList(counts=counts),
                            colData=colData)
se0

## Save 'se0' as an HDF5-based SummarizedExperiment object:
dir <- sub("file", "h5_se0_", tempfile())
h5_se0 <- saveHDF5SummarizedExperiment(se0, dir)
h5_se0
assay(h5_se0, withDimnames=FALSE)  # HDF5Matrix object

h5_se0b <- loadHDF5SummarizedExperiment(dir)
h5_se0b
assay(h5_se0b, withDimnames=FALSE)  # HDF5Matrix object

## Sanity checks:
stopifnot(is(assay(h5_se0, withDimnames=FALSE), "HDF5Matrix"))
stopifnot(all(DelayedArray(assay(se0)) == assay(h5_se0)))
stopifnot(is(assay(h5_se0b, withDimnames=FALSE), "HDF5Matrix"))
stopifnot(all(DelayedArray(assay(se0)) == assay(h5_se0b)))

## ---------------------------------------------------------------------
## More sanity checks
## ---------------------------------------------------------------------

## Make a copy of directory 'dir':
somedir <- sub("file", "somedir", tempfile())
dir.create(somedir)
file.copy(dir, somedir, recursive=TRUE)
dir2 <- list.files(somedir, full.names=TRUE)

## 'dir2' contains a copy of 'dir'. Call loadHDF5SummarizedExperiment()
## on it.
h5_se0c <- loadHDF5SummarizedExperiment(dir2)

stopifnot(is(assay(h5_se0c, withDimnames=FALSE), "HDF5Matrix"))
stopifnot(all(DelayedArray(assay(se0)) == assay(h5_se0c)))
}

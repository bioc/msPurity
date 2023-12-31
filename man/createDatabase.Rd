% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/createDatabase.R
\name{createDatabase}
\alias{createDatabase}
\title{Create database}
\usage{
createDatabase(
  pa,
  xcmsObj,
  xsa = NULL,
  outDir = ".",
  grpPeaklist = NA,
  dbName = NA,
  metadata = NA,
  xset = NA
)
}
\arguments{
\item{pa}{purityA object; Needs to be the same used for frag4feature function}

\item{xcmsObj}{xcms object of class XCMSnExp or xcmsSet; Needs to be the same used for frag4feature function (this will be ignored when using xsa parameter)}

\item{xsa}{CAMERA object (optional); if CAMERA object is used, we ignore the xset parameter input and obtain all information
from the xset object nested with the CAMERA xsa object. Adduct and isotope information
will be included into the database when using this parameter. The underlying xset object must
be the one used for the frag4feature function}

\item{outDir}{character; Out directory for the SQLite result database}

\item{grpPeaklist}{dataframe (optional); Can use any peak dataframe. Still needs to be derived from the xset object though}

\item{dbName}{character (optional); Name of the result database}

\item{metadata}{list; A list of metadata to add to the s_peak_meta table}

\item{xset}{xcms object of class XCMSnExp or xcmsSet; (Deprecated - if provided, will replace variable 'obj')}
}
\value{
path to SQLite database and database name
}
\description{
\strong{General}

Create an SQLite database of an LC-MS(/MS) experiment (replaces the create_database function).

Schema details can be found \href{https://bioconductor.org/packages/release/bioc/vignettes/msPurity/inst/doc/msPurity-spectral-datatabase-schema.html}{here}.

\strong{Example LC-MS/MS processing workflow}
\itemize{
\item Purity assessments
\itemize{
\item (mzML files) -> purityA -> (pa)
}
\item XCMS processing
\itemize{
\item (mzML files) -> xcms.findChromPeaks -> (optionally) xcms.adjustRtime -> xcms.groupChromPeaks -> (xcmsObj)
\item --- \emph{Older versions of XCMS} --- (mzML files) -> xcms.xcmsSet -> xcms.group -> xcms.retcor -> xcms.group -> (xcmsObj)
}
\item Fragmentation processing
\itemize{
\item (xcmsObj, pa) -> frag4feature -> filterFragSpectra -> averageAllFragSpectra -> \strong{createDatabase} -> spectralMatching -> (sqlite spectral database)
}
}
}
\examples{
library(xcms)
library(MSnbase)
library(magrittr)
#====== XCMS =================================
## Read in MS data
msmsPths <- list.files(system.file("extdata", "lcms", "mzML",
           package="msPurityData"), full.names = TRUE, pattern = "MSMS")
ms_data = readMSData(msmsPths, mode = 'onDisk', msLevel. = 1)

## Find peaks in each file
cwp <- CentWaveParam(snthresh = 5, noise = 100, ppm = 10, peakwidth = c(3, 30))
xcmsObj  <- xcms::findChromPeaks(ms_data, param = cwp)

## Optionally adjust retention time
xcmsObj  <- adjustRtime(xcmsObj , param = ObiwarpParam(binSize = 0.6))

## Group features across samples
pdp <- PeakDensityParam(sampleGroups = c(1, 1), minFraction = 0, bw = 30)
xcmsObj <- groupChromPeaks(xcmsObj , param = pdp)

#====== msPurity ============================
pa  <- purityA(msmsPths)
pa <- frag4feature(pa = pa, xcmsObj = xcmsObj)
pa <- filterFragSpectra(pa, allfrag=TRUE)
pa <- averageAllFragSpectra(pa)
dbPth <- createDatabase(pa, xcmsObj, metadata=list('polarity'='positive','instrument'='Q-Exactive'))

td <- tempdir()
db_pth = createDatabase(pa = pa, xcmsObj = xcmsObj, outDir = td)

}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/purityA-filter-frag-spectra.R
\name{filterFragSpectra,purityA-method}
\alias{filterFragSpectra,purityA-method}
\alias{filterFragSpectra}
\title{Filter fragmentation spectra associated with an XCMS feature}
\usage{
\S4method{filterFragSpectra}{purityA}(
  pa,
  ilim = 0,
  plim = 0.8,
  ra = 0,
  snr = 3,
  rmp = FALSE,
  snmeth = "median",
  allfrag = FALSE
)
}
\arguments{
\item{pa}{object; purityA object}

\item{ilim}{numeric; min intensity of a peak}

\item{plim}{numeric; min precursor ion purity of the associated precursor for fragmentation spectra scan}

\item{ra}{numeric; minimum relative abundance of a peak}

\item{snr}{numeric; minimum signal-to-noise of a peak within each file}

\item{rmp}{boolean; TRUE if peaks are to be removed that do not meet the threshold criteria. Otherwise they will just be flagged.}

\item{snmeth}{character; Method to calculate signal to noise ration (either median or mean)}

\item{allfrag}{boolean; Whether to filter on all fragmentation spectra or just the fragmentation spectra grouped to XCMS feature}
}
\value{
Returns a purityA object with the pa@grped_msms spectra matrices are updated with the following columns
\itemize{
\item snr: Signal to noise ratio (calculated at scan level)
\item ra: Relative abundance (calculated at scan level)
\item purity_pass_flag: Precursor ion purity flag (1 pass, 0 fail)
\item intensity_pass_flag: Intensity flag (1 pass, 0 fail)
\item snr_pass_flag: Signal-to-noise pass flag (1 pass, 0 fail)
\item ra_pass_flag: Relative abundance pass flag (1 pass, 0 fail)
\item pass_flag: Overall pass flag, all flags must pass for this to pass (1 pass, 0 fail)
}
}
\description{
\strong{General}

Flag and filter features based on signal-to-noise ratio, relative abundance, intensity threshold and purity of the precursor ion.

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
\item (xcmsObj, pa) -> frag4feature -> \strong{filterFragSpectra} -> averageAllFragSpectra -> createDatabase -> spectralMatching -> (sqlite spectral database)
}
}
}
\examples{
#====== XCMS =================================
## Read in MS data
#msmsPths <- list.files(system.file("extdata", "lcms", "mzML",
#           package="msPurityData"), full.names = TRUE, pattern = "MSMS")
#ms_data = readMSData(msmsPths, mode = 'onDisk', msLevel. = 1)

## Find peaks in each file
#cwp <- CentWaveParam(snthresh = 5, noise = 100, ppm = 10, peakwidth = c(3, 30))
#xcmsObj  <- xcms::findChromPeaks(ms_data, param = cwp)

## Optionally adjust retention time
#xcmsObj  <- adjustRtime(xcmsObj , param = ObiwarpParam(binSize = 0.6))

## Group features across samples
#pdp <- PeakDensityParam(sampleGroups = c(1, 1), minFraction = 0, bw = 30)
#xcmsObj <- groupChromPeaks(xcmsObj , param = pdp)

#====== msPurity ============================
#pa  <- purityA(msmsPths)
#pa <- frag4feature(pa, xcmsObj)
#pa <- filterFragSpectra(pa)

## Run from previously generated data
pa <- readRDS(system.file("extdata", "tests", "purityA",
                          "2_frag4feature_pa.rds", package="msPurity"))
pa <- filterFragSpectra(pa)

}

## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
library(msPurity)
library(xcms)
mzMLpths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE)

#read in the data
xset = xcms::xcmsSet(mzMLpths, method = 'centWave', mslevel=1, snthresh = 3, noise = 100, ppm = 10, peakwidth = c(3, 30))

#for this example we will subset the data to focus on retention time range 30-90 seconds and scan range 100-200 m/z
xset@peaks = xset@peaks[xset@peaks[,4] >= 30 & xset@peaks[,4] <= 90,] #retention time filter
xset@peaks = xset@peaks[xset@peaks[,1] >= 100 & xset@peaks[,1] <= 200,] #m/z filter

#group features across samples
xset = xcms::group(xset, minfrac = 0, bw = 5, mzwid = 0.017)
xcmsObj = xset

## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
library(msPurity)
library(magrittr)
library(xcms)
library(MSnbase)
mzMLpths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE)

#read in data and subset to use data between 30 and 90 seconds and 100 and 200 m/z
msdata = readMSData(mzMLpths, mode = 'onDisk', msLevel. = 1)
rtr = c(30, 90)
mzr = c(100, 200)
msdata = msdata %>%  MSnbase::filterRt(rt = rtr) %>%  MSnbase::filterMz(mz = mzr)

#perform feature detection in individual files
cwp <- CentWaveParam(snthresh = 3, noise = 100, ppm = 10, peakwidth = c(3, 30))
xcmsObj <- xcms::findChromPeaks(msdata, param = cwp)
#update metadata
xcmsObj@phenoData@data$class = c('blank', 'blank', 'sample', 'sample')
xcmsObj@phenoData@varMetadata = data.frame('labelDescription' = c('sampleNames', 'class'))
#group chromatographic peaks across samples (correspondence analysis)
pdp <- PeakDensityParam(sampleGroups = xcmsObj@phenoData@data$class, minFraction = 0, bw = 5, binSize = 0.017)
xcmsObj <- groupChromPeaks(xcmsObj, param = pdp)


## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
pa  <- purityA(mzMLpths)
pa <- frag4feature(pa = pa, xcmsObj = xcmsObj)

## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
pa <- filterFragSpectra(pa = pa)

## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
pa <- averageIntraFragSpectra(pa = pa) # use parameters specific to intra spectra 
pa <- averageInterFragSpectra(pa = pa) # use parameters specific to inter spectra

## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
pa <- averageAllFragSpectra(pa = pa) 

## ----results='hide', message=FALSE, warning=FALSE,  echo = TRUE---------------
td <- tempdir()
q_dbPth <- createDatabase(pa = pa, xcmsObj = xcmsObj, outDir = td, dbName = 'lcmsms-processing.sqlite')

## -----------------------------------------------------------------------------
result <- spectralMatching(q_dbPth, q_xcmsGroups = c(432), l_accessions=c('CCMSLIB00003740033'))
print(result)


## ------------------------------------------------------------------------
library(msPurity)
msmsPths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE, pattern = "MSMS")
msPths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE, pattern = "LCMS_")

## ------------------------------------------------------------------------
pa <- purityA(msmsPths)

print(head(pa@puritydf))

## ------------------------------------------------------------------------
library(xcms)

xset <- xcms::xcmsSet(msmsPths)
xset <- xcms::group(xset)
xset <- xcms::retcor(xset)
xset <- xcms::group(xset)

## ------------------------------------------------------------------------
pa <- frag4feature(pa, xset)

## ------------------------------------------------------------------------
print(head(pa@grped_df))

## ------------------------------------------------------------------------
print(pa@grped_ms2[2:3])

## ------------------------------------------------------------------------
xset <- xcms::xcmsSet(msPths)
xset <- xcms::group(xset)
xset <- xcms::retcor(xset)
xset <- xcms::group(xset)

## ------------------------------------------------------------------------
ppLCMS <- purityX(xset, offsets=c(0.5, 0.5), xgroups = c(1, 2))

print(head(ppLCMS@predictions))

## ------------------------------------------------------------------------
datapth <- system.file("extdata", "dims", "mzML", package="msPurityData")
inDF <- Getfiles(datapth, pattern=".mzML", check = FALSE)
ppDIMS <- purityD(inDF, mzML=TRUE)

## ------------------------------------------------------------------------
ppDIMS <- averageSpectra(ppDIMS, snMeth = "median", snthr = 5)

## ------------------------------------------------------------------------
ppDIMS <- filterp(ppDIMS, thr=5000, rsd = 10)

## ------------------------------------------------------------------------
ppDIMS <- subtract(ppDIMS)

## ------------------------------------------------------------------------
ppDIMS <- dimsPredictPurity(ppDIMS)

print(head(ppDIMS@avPeaks$processed$B02_Daph_TEST_pos))

## ------------------------------------------------------------------------
mzpth <- system.file("extdata", "dims", "mzML", "B02_Daph_TEST_pos.mzML", package="msPurityData")
predicted <- dimsPredictPuritySingle(filepth = mzpth, mztargets = c(111.0436, 113.1069))
print(predicted)

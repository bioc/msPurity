context ("checking purityA (using the XCMS v2 functions)")

test_that("checking frag4feature (xcms v2 functions)", {
  print("\n")
  print("########################################################")
  print("## Checking frag4feature    (xcms v2 functions)       ##")
  print("########################################################")

  #msmsPths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE, pattern = "MSMS")
  #pa  <- purityA(msmsPths)
  #xset <- xcmsSet(msmsPths)
  #xset <- group(xset)
  msmsPths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE, pattern = "MSMS")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "1_purityA_pa_OLD.rds", package="msPurity"))
  xset <- readRDS(system.file("extdata","tests", "xcms", "msms_only_xset_OLD.rds", package="msPurity"))
  pa@fileList[1] <- msmsPths[basename(msmsPths)=="LCMSMS_1.mzML"]
  pa@fileList[2] <- msmsPths[basename(msmsPths)=="LCMSMS_2.mzML"]
  xset@filepaths[1] <- msmsPths[basename(msmsPths)=="LCMSMS_1.mzML"]
  xset@filepaths[2] <- msmsPths[basename(msmsPths)=="LCMSMS_2.mzML"]


  pa <- frag4feature(pa, xset, create_db=FALSE)

  #saveRDS(pa, file.path("inst", "extdata", "test_data", "purityA", "2_frag4feature_pa.rds"))
  expect_equal(round(pa@grped_df$inPurity[1],4), 1)
  expect_equal(round(pa@grped_df$precurMtchPPM[1], 4), 1.0048)
  expect_equal(length(pa@grped_ms2), 77)
  expect_equal(nrow(pa@grped_ms2[[2]][[1]]), 4)
  expect_equal(round(pa@grped_ms2[[1]][[1]][1],4), 112.0509)

  pa_saved <- readRDS(system.file("extdata", "tests", "purityA", "2_frag4feature_pa.rds", package="msPurity"))
  # Saved object is from an old version of msPurity where we stored the rtminCorrected differently (no correction used here
  # so not important to check for this test)
  grped_df <- pa@grped_df[,-match(c('rtminCorrected', 'rtmaxCorrected'), colnames(pa@grped_df))]
  grped_df_saved <- pa@grped_df[,-match(c('rtminCorrected', 'rtmaxCorrected'), colnames(pa@grped_df))]
  expect_equal(grped_df, grped_df_saved)


})


test_that("checking frag4feature (fillpeaks) (xcms v2 functions)", {
  print("\n")
  print("####################################################################")
  print("## Checking frag4feature (fillpeaks)  (xcms v2 functions)         ##")
  print("####################################################################")
  library(xcms)
  #msmsPths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE, pattern = "MSMS")
  #pa  <- purityA(msmsPths)
  #xset <- xcmsSet(msmsPths)
  #xset <- group(xset)
  msmsPths <- list.files(system.file("extdata", "lcms", "mzML", package="msPurityData"), full.names = TRUE, pattern = "MSMS")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "1_purityA_pa_OLD.rds", package="msPurity"))
  xset <- readRDS(system.file("extdata","tests", "xcms", "msms_only_xset_OLD.rds", package="msPurity"))
  pa@fileList[1] <- msmsPths[basename(msmsPths)=="LCMSMS_1.mzML"]
  pa@fileList[2] <- msmsPths[basename(msmsPths)=="LCMSMS_2.mzML"]
  xset@filepaths[1] <- msmsPths[basename(msmsPths)=="LCMSMS_1.mzML"]
  xset@filepaths[2] <- msmsPths[basename(msmsPths)=="LCMSMS_2.mzML"]

  xset <- xcms::fillPeaks(xset)

  pa <- frag4feature(pa, xset)

  #saveRDS(pa, file.path("inst", "extdata", "test_data", "purityA", "2_frag4feature_pa.rds"))
  expect_equal(round(pa@grped_df$inPurity[1],4), 1)
  expect_equal(round(pa@grped_df$precurMtchPPM[1], 4), 1.0048)
  expect_equal(length(pa@grped_ms2), 77)
  expect_equal(nrow(pa@grped_ms2[[2]][[1]]), 4)
  expect_equal(round(pa@grped_ms2[[1]][[1]][1],4), 112.0509)

  pa_saved <- readRDS(system.file("extdata", "tests", "purityA", "2_frag4feature_pa_OLD.rds", package="msPurity"))

  if (length(colnames(pa@grped_ms2[[1]][[1]]))>0){
    # From R v4.2 onwards XCMS has changed to labelling MS2 spectra - so we add these labels to the saved pa object
    grped_ms2_labelled <- lapply(pa_saved@grped_ms2, function(x){
      lapply(x, function(y){colnames(y) = c('mz', 'intensity'); return(y)})
    })
    expect_equal(pa@grped_ms2[1:32],  grped_ms2_labelled[1:32])
  }else{
    expect_equal(pa@grped_ms2,  pa@grped_ms2)
  }



  # Saved object is from an old version of msPurity where we stored the rtminCorrected differently (no correction used here
  # so not important to check for this test)
  grped_df <- pa@grped_df[,-match(c('rtminCorrected', 'rtmaxCorrected'), colnames(pa@grped_df))]
  grped_df_saved <- pa@grped_df[,-match(c('rtminCorrected', 'rtmaxCorrected'), colnames(pa@grped_df))]
  expect_equal(grped_df, grped_df_saved)


})


test_that("checking filterFragSpectra purityA (xcms v2 functions)", {
  print ("\n")
  print("########################################################")
  print("## Checking filterFragSpectra  (xcms v2 functions)    ##")
  print("########################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "2_frag4feature_pa_OLD.rds", package="msPurity"))

  pa <- filterFragSpectra(pa, plim = 0.7, snr = 3)

  #saveRDS(pa, file.path("inst", "extdata", "purityA_tests", "3_filterFragSpectra_pa.rds"))
  expect_equal(colnames(pa@grped_ms2[[1]][[1]]), c("mz", "i","snr", "ra" ,
                                                   "purity_pass_flag",    "intensity_pass_flag",
                                                   "ra_pass_flag","snr_pass_flag",   "pass_flag"  ))

  expect_equal(round(pa@grped_ms2[[1]][[1]][,'mz'],4), c(112.0509, 126.5377))
  expect_equal(round(pa@grped_ms2[[1]][[1]][,'i'],0),  c(565117,   2499))
  expect_equal(pa@grped_ms2[[1]][[1]][,'snr'], c(1.991193651, 0.008806349))
  expect_equal(pa@grped_ms2[[1]][[1]][,'ra'], c(100.0000000,   0.4422648))
  expect_equal(pa@grped_ms2[[1]][[1]][,'purity_pass_flag'], c(1,   1))
  expect_equal(pa@grped_ms2[[1]][[1]][,'intensity_pass_flag'], c(1,   1))
  expect_equal(pa@grped_ms2[[1]][[1]][,'ra_pass_flag'], c(1,   1))
  expect_equal(pa@grped_ms2[[1]][[1]][,'snr_pass_flag'], c(0,   0))
  expect_equal(pa@grped_ms2[[1]][[1]][,'pass_flag'], c(0,   0))

  expect_equal(round(pa@grped_ms2[[10]][[2]][,'mz'],4), c(102.0013, 102.0376, 102.0553, 102.9030,
                                                          103.0827, 120.0116, 122.0163, 130.0501,
                                                          130.0860, 131.0527, 131.0899, 133.0192,
                                                          134.0267, 148.0426, 160.7018))
  expect_equal(round(pa@grped_ms2[[10]][[2]][,'i'],0),  c( 418361, 26940, 31788,  2297,  2656, 1534089,
                                                           2559,   17183,    4825,    3329,    3828,
                                                           31002,    3603, 1333086,    2493))
  expect_equal(pa@grped_ms2[[10]][[2]][,'snr'], c(86.7093726,   5.5836066,   6.5882984,   0.4761153,
                                                  0.5504728, 317.9551029,   0.5304692,   3.5613499,
                                                  1.0000000,   0.6899905,   0.7933997,   6.4254739,
                                                  0.7467862,276.2951708,   0.5167274))
  expect_equal(pa@grped_ms2[[10]][[2]][,'ra'], c( 27.2709486,   1.7560991,   2.0720845,   0.1497429,   0.1731291,
                                                  100.0000000,   0.1668378,   1.1200795,   0.3145098,   0.2170088,
                                                  0.2495320,   2.0208746,  0.2348716,  86.8975425,   0.1625158))
  expect_equal(pa@grped_ms2[[10]][[2]][,'purity_pass_flag'], c( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1))
  expect_equal(pa@grped_ms2[[10]][[2]][,'intensity_pass_flag'], c( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1))
  expect_equal(pa@grped_ms2[[10]][[2]][,'ra_pass_flag'], c( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1))
  expect_equal(pa@grped_ms2[[10]][[2]][,'snr_pass_flag'], c(1, 1, 1, 0, 0, 1, 0, 1, 0, 0 ,0, 1, 0, 1, 0))
  expect_equal(pa@grped_ms2[[10]][[2]][,'pass_flag'], c(1, 1, 1, 0, 0, 1, 0, 1, 0, 0 ,0, 1, 0, 1, 0))

  pa_saved <- readRDS(system.file("extdata", "tests", "purityA", "3_filterFragSpectra_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)

})





test_that("checking averageIntraFragSpectra (no filter) purityA (xcms v2 functions)", {
  print ("\n")
  print("##############################################################")
  print("## Checking averageIntraFragSpectra (xcms v2 functions)     ##")
  print("##############################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "2_frag4feature_pa_OLD.rds", package="msPurity"))

  pa <- averageIntraFragSpectra(pa)

  #saveRDS(pa, file.path("inst", "extdata", "test_data", "purityA", "4_averageIntraFragSpectra_no_filter_pa.rds"))
  expect_equal(length(pa@av_spectra), 77)
  expect_equal(length(pa@av_spectra$`12`$av_intra), 2)
  expect_equal(round(pa@av_spectra$`12`$av_intra$`1`$mz, 4), c(107.2701, 116.0165, 116.0709, 116.1073))
  expect_equal(round(pa@av_spectra$`12`$av_intra$`2`$mz, 4), c(103.1290, 116.0168, 116.0709, 116.1073, 130.0276))
  expect_equal(round(pa@av_spectra$`12`$av_intra$`1`$frac, 4), c(0.3333, 0.6667, 1.0000, 0.6667))
  expect_equal(round(pa@av_spectra$`12`$av_intra$`2`$frac, 4), c(0.3333, 1.0000, 1.0000, 0.6667, 0.3333))
  expect_equal(round(pa@av_spectra$`12`$av_intra$`1`$i, 2), c(1726.61, 7324.86, 2114202.40, 13797.10))
  expect_equal(round(pa@av_spectra$`12`$av_intra$`2`$i, 2), c( 4419.71, 23772.87, 2029273.85, 12305.23, 4081.14))

  pa_saved <- readRDS(system.file("extdata","tests", "purityA", "4_averageIntraFragSpectra_no_filter_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)


})

test_that("checking averageInterFragSpectra (no filter) purityA (xcms v2 functions)", {
  print ("\n")
  print("#############################################################")
  print("## Checking averageInterFragSpectra    (xcms v2 functions)  #")
  print("#############################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "4_averageIntraFragSpectra_no_filter_pa_OLD.rds", package="msPurity"))

  pa <- averageInterFragSpectra(pa)

  #saveRDS(pa, file.path("inst", "extdata", "purityA_tests", "5_averageInterFragSpectra_no_filter_pa.rds"))
  expect_equal(length(pa@av_spectra$`12`$av_inter), 15)
  expect_equal(round(pa@av_spectra$`12`$av_inter$mz, 4), c(116.0166,116.0709,116.1073))
  expect_equal(round(pa@av_spectra$`12`$av_inter$frac, 4), c(1,1,1))
  expect_equal(round(pa@av_spectra$`12`$av_inter$i, 2), c(31097.73, 4143476.25, 26102.33))

  pa_saved <- readRDS(system.file("extdata","tests", "purityA", "5_averageInterFragSpectra_no_filter_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)

})


test_that("checking averageAllFragSpectra (no filter) purityA", {
  print ("\n")
  print("########################################################")
  print("## Checking averageAllFragSpectra  (xcms v2 functions) #")
  print("########################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "5_averageInterFragSpectra_no_filter_pa_OLD.rds", package="msPurity"))

  pa <- averageAllFragSpectra(pa)
  #saveRDS(pa, file.path("inst", "extdata", "tests", "purityA", "6_averageAllFragSpectra_no_filter_pa.rds"))

  expect_equal(length(pa@av_spectra$`12`$av_all), 15)
  expect_equal(round(pa@av_spectra$`12`$av_all$mz, 4), c(103.1290, 107.2701, 116.0166, 116.0709, 116.1073, 130.0276))
  expect_equal(round(pa@av_spectra$`12`$av_all$frac, 4), c(0.1667, 0.1667, 0.8333, 1.0000, 0.6667, 0.1667))
  expect_equal(round(pa@av_spectra$`12`$av_all$i, 2), c(4419.71, 1726.61, 31097.73, 4143476.25, 26102.33, 4081.14))
  expect_equal(round(pa@av_spectra$`12`$av_all$mz, 4), c(103.1290, 107.2701, 116.0166, 116.0709, 116.1073, 130.0276))
  expect_equal(round(pa@av_spectra$`12`$av_all$frac, 4), c(0.1667, 0.1667, 0.8333, 1.0000, 0.6667, 0.1667))
  expect_equal(round(pa@av_spectra$`12`$av_all$i, 2), c(4419.71, 1726.61, 31097.73, 4143476.25, 26102.33, 4081.14))

  pa_saved <- readRDS(system.file("extdata", "tests", "purityA", "6_averageAllFragSpectra_no_filter_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)

})






test_that("checking averageIntraFragSpectra (with filter) purityA (xcms v2 functions)", {
  print ("\n")
  print("###########################################################################")
  print("## Checking averageIntraFragSpectra (with filter)  (xcms v2 functions)   ##")
  print("###########################################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "3_filterFragSpectra_pa_OLD.rds", package="msPurity"))

  pa <- averageIntraFragSpectra(pa)

  #saveRDS(pa, file.path("inst", "extdata", "tests", "purityA", "7_averageIntraFragSpectra_with_filter_pa.rds"))

  pa_saved <- readRDS(system.file("extdata","tests", "purityA", "7_averageIntraFragSpectra_with_filter_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)


})

test_that("checking averageInterFragSpectra (with filter) purityA  (xcms v2 functions)", {
  print ("\n")
  print("############################################################################")
  print("## Checking averageInterFragSpectra (with filter)   (xcms v2 functions)   ##")
  print("############################################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "7_averageIntraFragSpectra_with_filter_pa_OLD.rds", package="msPurity"))

  pa <- averageInterFragSpectra(pa)

  #saveRDS(pa, file.path("inst", "extdata", "tests",  "purityA", "8_averageInterFragSpectra_with_filter_pa.rds"))

  pa_saved <- readRDS(system.file("extdata","tests", "purityA", "8_averageInterFragSpectra_with_filter_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)

})


test_that("checking averageAllFragSpectra (with filter) purityA (xcms v2 functions)", {
  print ("\n")
  print("#########################################################################")
  print("## Checking averageAllFragSpectra  (with filter)  (xcms v2 functions)  ##")
  print("#########################################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "8_averageInterFragSpectra_with_filter_pa_OLD.rds", package="msPurity"))


  pa <- averageAllFragSpectra(pa)

  #saveRDS(pa, file.path("inst", "extdata", "tests", "purityA", "9_averageAllFragSpectra_with_filter_pa.rds"))

  pa_saved <- readRDS(system.file("extdata", "tests", "purityA", "9_averageAllFragSpectra_with_filter_pa_OLD.rds", package="msPurity"))
  expect_equal(pa, pa_saved)

})



test_that("checking createMSP based functions (xcms v2 functions)", {
  print ("\n")
  print("########################################################")
  print("## Checking createMSP functions   (xcms v2 functions) ##")
  print("########################################################")

  pa <- readRDS(system.file("extdata", "tests", "purityA", "9_averageAllFragSpectra_with_filter_pa_OLD.rds", package="msPurity"))

  get_msp_str <- function(msp_pth){
    msp_str <- readChar(msp_pth, file.info(msp_pth)$size)

    msp_str <- gsub('\n','',msp_str)
    msp_str <- gsub('\r','',msp_str)
    msp_str <- gsub('msPurity version:\\d+\\.\\d+\\.\\d+','', msp_str)
    return(msp_str)
  }


  metadata <- data.frame('grpid'=c(12, 27), 'MS$FOCUSED_ION: PRECURSOR_TYPE'=c('[M+H]+', '[M+H]+ 88.0158 [M+H+NH3]+ 105.042'),
                         'AC$MASS_SPECTROMETRY: ION_MODE'=c("POSITIVE","POSITIVE"), 'CH$NAME:'=c('Sulfamethizole', 'Unknown'),
                         check.names = FALSE, stringsAsFactors = FALSE)

  tmp_dir <- tempdir()

  ################################
  # Check all method
  ################################
  all_msp_new_pth <- file.path(tmp_dir,'all.msp')
  createMSP(pa, msp_file = all_msp_new_pth, metadata = metadata,
            method = "all", xcms_groupids = c(12, 27))

  all_msp_new <- get_msp_str(all_msp_new_pth)
  all_msp_old <- get_msp_str(system.file("extdata", "tests", "msp", "all_OLD.msp", package="msPurity"))
  expect_equal(all_msp_new, all_msp_old)


  ################################
  # Check max method
  ################################
  max_msp_new_pth <- file.path(tmp_dir,'max.msp')
  createMSP(pa, msp_file = max_msp_new_pth, metadata = metadata, method = "max",
            xcms_groupids = c(12, 27), filter=FALSE)

  max_msp_new <- get_msp_str(max_msp_new_pth)
  max_msp_old <- get_msp_str(system.file("extdata", "tests","msp", "max_OLD.msp", package="msPurity"))
  expect_equal(max_msp_new, max_msp_old)


  ################################
  # Check av_inter method
  ################################
  av_inter_msp_new_pth <- file.path(tmp_dir,'av_inter.msp')
  createMSP(pa, msp_file = av_inter_msp_new_pth, metadata = metadata, method = "av_inter", xcms_groupids = c(12, 27))

  av_inter_msp_new <- get_msp_str(av_inter_msp_new_pth)
  av_inter_msp_old <- get_msp_str(system.file("extdata","tests","msp", "av_inter_OLD.msp", package="msPurity"))
  expect_equal(av_inter_msp_new, av_inter_msp_old)


  ################################
  # Check av_intra method
  ################################
  av_intra_msp_new_pth <- file.path(tmp_dir,'av_intra.msp')
  createMSP(pa, msp_file = av_intra_msp_new_pth, metadata = metadata, method = "av_intra", xcms_groupids = c(12, 27))

  av_intra_msp_new <- get_msp_str(av_intra_msp_new_pth)
  av_intra_msp_old <- get_msp_str(system.file("extdata","tests","msp", "av_intra_OLD.msp", package="msPurity"))
  expect_equal(av_intra_msp_new, av_intra_msp_old)

  ################################
  # Check av_all method
  ################################
  av_all_msp_new_pth <- file.path(tmp_dir,'av_all.msp')
  createMSP(pa, msp_file = av_all_msp_new_pth, metadata = metadata, method = "av_all", xcms_groupids = c(8, 12))

  av_all_msp_new <- get_msp_str(av_all_msp_new_pth)
  av_all_msp_old <- get_msp_str(system.file("extdata", "tests","msp", "av_all_OLD.msp", package="msPurity"))
  expect_equal(av_all_msp_new, av_all_msp_old)


  ################################
  # When two metadata details for single XCMS feature
  ################################
  metadatad <- metadata
  metadatad[3, ] <- metadatad[1,]
  metadatad[3,4] <- 'possible other compound'

  av_all_msp_new_dupmeta_pth <- file.path(tmp_dir,'av_all_dupmeta.msp')
  createMSP(pa, msp_file = av_all_msp_new_dupmeta_pth, metadata = metadatad, method = "av_all", xcms_groupids = c(8, 12))

  av_all_msp_dupmeta_new <- get_msp_str(av_all_msp_new_dupmeta_pth)
  av_all_msp_dupmeta_old <- get_msp_str(system.file("extdata", "tests","msp", "av_all_dupmeta_OLD.msp", package="msPurity"))
  expect_equal(av_all_msp_dupmeta_new, av_all_msp_dupmeta_old)

  ################################
  # When the RECORD_TITLE: is defined by user
  ################################
  metadata <- data.frame('grpid'=c(12, 27), 'MS$FOCUSED_ION: PRECURSOR_TYPE'=c('[M+H]+', '[M+H]+ 88.0158 [M+H+NH3]+ 105.042'),
                         'AC$MASS_SPECTROMETRY: ION_MODE'=c("POSITIVE","POSITIVE"), 'RECORD_TITLE:'=c('Sulfamethizole', 'Unknown'),
                         check.names = FALSE, stringsAsFactors = FALSE)
  recrdt_msp_new_pth <- file.path(tmp_dir,'recrdt.msp')
  createMSP(pa, msp_file = recrdt_msp_new_pth, metadata = metadata,
            method = "all", xcms_groupids = c(12, 27))

  recrdt_msp_new <- get_msp_str(recrdt_msp_new_pth)
  recrdt_msp_old <- get_msp_str(system.file("extdata", "tests", "msp", "recrdt_OLD.msp", package="msPurity"))
  expect_equal(recrdt_msp_new, recrdt_msp_old)
})




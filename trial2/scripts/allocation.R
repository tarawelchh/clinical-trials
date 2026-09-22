library(gtsummary)
library(Minirand)

set.seed(123)
data <- read.csv("summative2/data/participant_data.csv")
head(data)

# Bin continuous variables first (using your pre-specified boundaries)
data$age_bin[data$Age < 20] <- "Under 20"
data$age_bin[data$Age >= 20 & data$Age < 30] <- "20 to 29"
data$age_bin[data$Age >= 30] <- "30 plus"

data$stee_bin <- ifelse(data$baseline_STEE < 5, "Less than 5", "At least 5")
data$age_bin <- as.factor(data$age_bin)
data$stee_bin <- as.factor(data$stee_bin)
data$StressScore <- as.factor(data$StressScore)
data$Sex <- as.factor(data$Sex)

# Build covmat with factors only
covmat <- data[, c("Sex", "StressScore", "age_bin", "stee_bin")]


### minimisation #####
## Information about the treatment
ntrt <- 2 # There will three treatment groups
trtseq <- c(1, 2) # the treatment groups are indexed 1, 2, 3
ratio <- c(1, 1) # the treatment groups will be allocated in a 2:2:1 ratio

## The next few rows generate the participant data frame
nsample <- 512
# label of the covariates
covwt <- c(1 / 4, 1 / 4, 1 / 4, 1 / 4) # equal weights/importance applied to each factor

res <- rep(NA, nsample) # Generate a vector to store the results (the allocations)
# generate treatment assignment for the 1st subject
res[1] <- sample(trtseq, 1, replace = TRUE, prob = ratio / sum(ratio))
# work through the remaining patients sequentially
for (j in 2:nsample)
{
  # get treatment assignment sequentially for all subjects
  # The vector res is updated and so all previous allocations are accounted for
  # covmat is the data frame of participant data
  res[j] <- Minirand(
    covmat = covmat, j, covwt = covwt, ratio = ratio, ntrt = ntrt, trtseq = trtseq, method = "Range", result = res, p = 0.9
  )
}
## Store the allocation vector 'res' as 'trt1'
trt1 <- res

# Display the number of randomized subjects at covariate factors
balance1 <- randbalance(trt1, covmat, ntrt, trtseq)
balance1

data$treat <- factor(res, levels = c(1, 2), labels = c("A", "B"))

data |>
  dplyr::select(Age, Sex, StressScore, baseline_STEE, treat) |>
  tbl_summary(by = "treat")

imbalance <- function(
  df, # participant data frame with allocation column included
  alloc # name of allocation column
) {
  alloc_vec <- as.factor(df[, names(df) == alloc])
  alloc_lev <- levels(alloc_vec) # how the treatment groups are coded
  n1 <- nrow(df[df[alloc] == alloc_lev[1], ])
  n2 <- nrow(df[df[alloc] == alloc_lev[2], ])
  abs(n1 - n2)
}

marg_imbalance <- function(
  df, # participant data frame, including allocation and all factor variables
  alloc, # name of allocation column
  factors # names of prognostic factors to be included
) {
  df <- as.data.frame(df) # deals with tibbles
  n_fact <- length(factors) # the numbers of factors
  imb_sum <- 0 # a running total of imbalance
  for (i in 1:n_fact) { # loop through the factors
    ind_i <- (1:ncol(df))[names(df) == factors[i]]
    col_i <- as.factor(df[, ind_i])
    levels_i <- levels(col_i)
    nlevels_i <- length(levels_i)
    for (j in 1:nlevels_i) { # loop through the levels of factor i
      # df_ij contains just those entries with level j of factor i
      df_ij <- df[df[, ind_i] == levels_i[j], ]
      imb_ij <- imbalance(df = df_ij, alloc = alloc) # find the imbalance for the sub-data-frame in which factor i has level j
      imb_sum <- imb_sum + imb_ij
    }
  }
  imb_sum
}

imbalance(data[, c(3, 4, 6, 7, 8)], alloc = "treat")
marg_imbalance(data, alloc = "treat", factors = c("StressScore"))


data_upload <- data[, c(1, 2, 3, 4, 5)]
data_upload[, "arm"] <- data$treat
# write.csv(data_upload, file = "allocated.csv", quote=FALSE, row.names=FALSE)
check <- read.csv("summative2/data/allocated.csv")

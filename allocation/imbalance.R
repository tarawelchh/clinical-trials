install.packages(c(
  "medicaldata", "ggplot2", "gtsummary", "Minirand",
  "blockrand", "dplyr", "randomizeR"
))
library(medicaldata)
library(gtsummary)
library(Minirand)

data("licorice_gargle")

# seven baseline characteristics, prefixed by pre0p

str(licorice_gargle) # shows all columns are numeric

lic_garg <- licorice_gargle[, 1:8]
# vector of names of columns to be coerced to factor
cols <- c(
  "preOp_gender", "preOp_asa",
  "preOp_mallampati", "preOp_smoking", "preOp_pain", "treat"
)
# convert each of those columns to factors
lic_garg[cols] <- lapply(lic_garg[cols], factor)

# Check the result:
str(lic_garg)
head(lic_garg)
tbl_summary(lic_garg, by = "treat")

rb_tab <- randbalance(
  trt = lic_garg$treat,
  covmat = lic_garg[, -8],
  ntrt = 2,
  trtseq = c("0", "1")
)
rb_tab$preOp_gender

# now want to group the age and BMI into bins

lic_garg$age[lic_garg$preOp_age < 50] <- "Under 50"
lic_garg$age[lic_garg$preOp_age >= 50 & lic_garg$preOp_age < 70] <- "50 to 70"
lic_garg$age[lic_garg$preOp_age >= 70] <- "70 plus"
lic_garg$age <- factor(lic_garg$age, levels = c("Under 50", "50 to 70", "70 plus"))

table(lic_garg$age)

lic_garg$BMI[lic_garg$preOp_calcBMI < 25] <- "medium_or_low"
lic_garg$BMI[lic_garg$preOp_calcBMI >= 25] <- "high"
lic_garg$BMI <- factor(lic_garg$BMI, levels = c("medium_or_low", "high"))
table(lic_garg$BMI)

lg_df <- lic_garg[, c(1, 2, 5, 6, 7, 9, 10, 8)]

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
imbalance(lg_df, "treat")

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

marg_imbalance(df = lg_df, alloc = "treat", factors = c("preOp_gender", "age"))
# Note that the larger the total number of factor levels, the larger the marginal
# imbalance will be, so if you’re comparing between methods, make sure you include all the same factors

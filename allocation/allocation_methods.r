source("allocation/imbalance.R")
# Simple Random Sampling#

srs <- function(
  df, # DF should be the participant data frame.
  # A column 'treat' will be added
  levels = c("0", "1") # Levels of treat factor
) {
    n <- nrow(df) # number of rows / participants
    # Create a new column 'treat'
    df$treat <- rep(NA, n)
    # work through the rows, randomly allocating patients with probably 1/2
    for (i in 1:n) {
        df$treat[i] <- sample(levels, size = 1, prob = c(0.5, 0.5))
    }
    df$treat <- as.factor(df$treat)
    df
}

lg_srs <- srs(df = lg_df[-8], levels = c("C", "T"))
tbl_summary(lg_srs, by = "treat")
imbalance(lg_srs, alloc = "treat")
lg_factors_all <- c(
    "preOp_gender", "preOp_asa", "preOp_mallampati", "preOp_smoking",
    "preOp_pain", "age", "BMI"
)
marg_imbalance(lg_srs, alloc = "treat", factors = lg_factors_all)

# Randomly Permuted Blocks#
library(blockrand)
rpb_lg <- blockrand(n = 235, levels = c("T", "C"))
lg_rpb <- lg_df
lg_rpb$treat <- rpb_lg$treatment[1:235]
tbl_summary(lg_rpb, by = "treat")
imbalance(lg_rpb, alloc = "treat")
marg_imbalance(lg_rpb, alloc = "treat", factors = lg_factors_all)

# Biased Coin Design#
biased_coin <- function(
  data,
  levels = c("T", "C"),
  p = 2 / 3
) {
    Dn <- 0 # starting value of imbalance
    n <- nrow(data)
    alloc <- rep(NA, n)

    for (i in 1:n) {
        if (Dn == 0) { # equally balanced
            alloc[i] <- sample(levels, size = 1, prob = c(0.5, 0.5))
        } else if (Dn < 0) { # More allocations to levels[2] up to this point
            alloc[i] <- sample(levels, size = 1, prob = c(p, 1 - p))
        } else if (Dn > 0) { # More allocations to levels[1] up to this point
            alloc[i] <- sample(levels, size = 1, prob = c(1 - p, p))
        }
        # Compute imbalance at this stage
        alloc_to_n <- alloc[1:i]
        Dn <- sum(alloc_to_n == levels[1]) - sum(alloc_to_n == levels[2])
    }
    data$treat <- as.factor(alloc)
    data
}

lg_bc <- biased_coin(lg_df[-8], p = 0.9)
tbl_summary(lg_bc, by = "treat")
imbalance(lg_bc, alloc = "treat")
marg_imbalance(lg_bc, alloc = "treat", factors = lg_factors_all)

# Urn Design#
library(randomizeR)
# function udPar, N is total sample size, ini is initial in urn (r), add is number added each step (s)
urn_31_lg <- udPar(235, 3, 1, groups = c("C", "T"))
urn_31_seq <- genSeq(urn_31_lg)
urn_31_seq$M[1, ]

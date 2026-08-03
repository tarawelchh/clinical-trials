source("allocation/imbalance.R")

### Minimisation #####

# Minirand works from the point of view of having already allocated
# j-1 particpants, and being presented with a jth

## Information about the treatment
ntrt <- 3 # There will three treatment groups
trtseq <- c(1, 2, 3) # the treatment groups are indexed 1, 2, 3
ratio <- c(2, 2, 1) # the treatment groups will be allocated in a 2:2:1 ratio

## The next few rows generate the participant data frame
nsample <- 120 # we will have 120 participants
c1 <- sample(seq(1, 0), nsample, replace = TRUE, prob = c(0.4, 0.6))
c2 <- sample(seq(1, 0), nsample, replace = TRUE, prob = c(0.3, 0.7))
c3 <- sample(c(2, 1, 0), nsample, replace = TRUE, prob = c(0.33, 0.2, 0.5))
c4 <- sample(seq(1, 0), nsample, replace = TRUE, prob = c(0.33, 0.67))
covmat <- cbind(c1, c2, c3, c4) # generate the matrix of covariate factors for the subjects
# label of the covariates
colnames(covmat) <- c("Gender", "Age", "Hypertension", "Use of Antibiotics")
covwt <- c(1 / 4, 1 / 4, 1 / 4, 1 / 4) # equal weights/importance applied to each factor

## Applying the algorithm - start here if you already have participant data!

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

# Calculate the total imbalance of the allocation
totimbal(
    trt = trt1, covmat = covmat, covwt = covwt,
    ratio = ratio, ntrt = ntrt, trtseq = trtseq, method = "Range"
)

# apply to licorice data

nsample <- nrow(lg_df)
res <- rep(NA, nsample)
res[1] <- sample(c(0, 1), 1, replace = TRUE, prob = c(0.5, 0.5))
# work through the remaining patients sequentially
for (j in 2:nsample) {
    # get treatment assignment sequentially for all subjects
    # The vector res is updated and so all previous allocations are accounted for
    # covmat is the data frame of participant data - including only the covariates
    res[j] <- Minirand(
        covmat = lg_df[, 1:7], j, covwt = rep(1, 7) / 7, ratio = c(1, 1),
        ntrt = 2, trtseq = c(0, 1), method = "Range", result = res, p = 0.9
    )
}

lg_df$treat <- res

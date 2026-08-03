source("allocation/imbalance.R")

## Stratifying the Dataset##

library(dplyr)
library(Minirand)
# Add an ID variable so that we can keep track of the order of participants
lg_df$ID <- 1:nrow(lg_df)
# split the data frame according to levels of factors
strat_gen_sm <- lg_df %>%
    group_split(preOp_gender, preOp_smoking)

strat_gen_sm[1]

group_sizes <- sapply(
    1:length(strat_gen_sm),
    function(i) {
        nrow(strat_gen_sm[[i]])
    }
)
group_sizes

lg_df |>
    group_by(preOp_gender, preOp_smoking) |>
    summarise(count = n())

# This command creates an empty list, which we will fill with allocation data frames as we go through
alloc_list <- list()
# The loop works through the stratified data frames, applies SRS to allocate patients
# and stores them in alloc_list
for (i in 1:length(strat_gen_sm)) {
    alloc_list[[i]] <- srs(strat_gen_sm[[i]])
}
# bind all the data frames back together again
alloc_full <- dplyr::bind_rows(alloc_list)
# re-order according to ID variable
alloc_full[order(alloc_full$ID), ]

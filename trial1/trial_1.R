set.seed(123)
library(ggplot2)
df <- read.csv("summative1/data/participant_data2.csv", header = TRUE)
library("dplyr")
library("broom")
library("blockrand")
library(car)
tbl_summary(df)
df
tbl_summary(df)
min(df[, "age"])
max(df[, "age"])

df_f <- df[df$sex == "F", ]
df_m <- df[df$sex == "M", ]
df_strat <- list(df_f, df_m)

# This command creates an empty list, which we will fill with allocation data frames as we go through
alloc_list <- list()
for (i in 1:length(df_strat)) {
  rows <- nrow(df_strat[[i]])
  alloc_list <- blockrand(n = rows, levels = c("A", "B"))
  df_strat[[i]]$arm <- (alloc_list$treatment)[1:rows]
}

# bind all the data frames back together again
alloc_full <- dplyr::bind_rows(df_strat)
# re-order according to ID variable
alloc_full[order(alloc_full$ID), ]

tbl_summary(alloc_full, by = arm)
tbl_summary(df_strat, by = arm)

# write.csv(alloc_full, file = "allocated2.csv", quote=FALSE, row.names=FALSE)

rb_tab <- randbalance(
  trt = alloc_full$treat,
  covmat = alloc_full[, -6],
  ntrt = 2,
  trtseq = c("0", "1")
)
rb_tab$sex

# imbalance = function(
#     df,   # participant data frame with allocation column included
#     alloc # name of allocation column
# ){
#   alloc_vec = as.factor(df[ ,names(df)==alloc])
#   alloc_lev = levels(alloc_vec) # how the treatment groups are coded
#   n1 = nrow(df[df[alloc]==alloc_lev[1],])
#   n2 = nrow(df[df[alloc]==alloc_lev[2],])
#   abs(n1-n2)
# }
# imbalance(alloc_full, "treat")
#
# marg_imbalance = function(
#     df,  # participant data frame, including allocation and all factor variables
#     alloc, # name of allocation column
#     factors # names of prognostic factors to be included
# ){
#   df = as.data.frame(df) # deals with tibbles
#   n_fact = length(factors) # the numbers of factors
#   imb_sum=0                # a running total of imbalance
#   for (i in 1:n_fact){     # loop through the factors
#     ind_i = (1:ncol(df))[names(df)==factors[i]]
#     col_i = as.factor(df[ ,ind_i])
#     levels_i = levels(col_i)
#     nlevels_i = length(levels_i)
#     for (j in 1:nlevels_i){ # loop through the levels of factor i
#       # df_ij contains just those entries with level j of factor i
#       df_ij = df[df[ ,ind_i]==levels_i[j] , ]
#       imb_ij = imbalance(df=df_ij, alloc=alloc) # find the imbalance for the sub-data-frame in which factor i has level j
#       imb_sum = imb_sum + imb_ij
#     }
#   }
#   imb_sum
# }
#
# marg_imbalance(alloc_full, "treat", c("sex"))

df <- read.csv("summative1/data/trial_results3.csv", header = TRUE)
df[, "sex"] <- as.factor(df[, "sex"])
df[, "wellness_score"] <- as.factor(df[, "wellness_score"])
tbl_summary(df, by = arm)
df[, "arm"] <- ifelse(df[, "arm"] == "A", "C", "T")
ggplot(df, aes(y = arm, x = baseline_tempdiff, fill = arm)) +
  ylab("Arm") +
  xlab("Baseline Temperature Differential") +
  geom_boxplot() +
  theme_bw()
ggplot(df, aes(baseline_tempdiff, arm, fill = arm)) +
  geom_boxplot() +
  xlab("Baseline Temperature Differential (°C)") +
  ylab("Arm") +
  theme_bw()
ggplot(df, aes(weight, arm, fill = arm)) +
  geom_boxplot() +
  xlab("Weight (kg)") +
  ylab("Arm") +
  theme_bw()
ggplot(df, aes(rmr, arm, fill = arm)) +
  geom_boxplot() +
  xlab("RMR (kcal/day") +
  ylab("Arm") +
  theme_bw()
ggplot(df, aes(age, arm, fill = arm)) +
  geom_boxplot() +
  xlab("Age (years)") +
  ylab("Arm") +
  theme_bw()

## VIF
rmrmodel <- lm(endline_tempdiff ~ baseline_tempdiff + sex + age + arm + weight + rmr, data = df)
vif(rmrmodel)

normrmodel <- lm(endline_tempdiff ~ baseline_tempdiff + sex + age + arm + weight, data = df)
vif(normrmodel)

summary(normrmodel)

smallmodel <- lm(endline_tempdiff ~ baseline_tempdiff * arm + sex + age, data = df)
summary(smallmodel)

model <- lm(endline_tempdiff ~ baseline_tempdiff + arm + sex + age + weight, data = df)
summary(model)

model2 <- lm(endline_tempdiff ~ baseline_tempdiff * arm + age + sex + weight, data = df)
nwmodel <- lm(endline_tempdiff ~ baseline_tempdiff * arm + age * arm + baseline_tempdiff * arm + sex + weight, data = df)

baseline_vars <- df[, c("age", "weight", "baseline_tempdiff")]
round(cor(baseline_vars), 2)

modeloutcome <- function(bstmp, ag, arm) {
  interact <- bstmp * arm
  outcome <- 1.34010 * bstmp + 0.26939 * ag - 0.66747 * interact - 17.12203
  return(outcome)
}
modeloutcome(8.744247, 61.35971, 1)
summary(normrmodel)
summary(nwmodel)
sumstats <- summary(model)
sumstats$coefficients
plot(model)

tbl_regression(model)
tbl_regression(model2)


m_weight <- mean(df[, "weight"])
m_baseline <- mean(df[, "baseline_tempdiff"])
df$nbl <- df[, "baseline_tempdiff"] - m_baseline
model3 <- lm(endline_tempdiff ~ nbl * arm + age + sex + weight, data = df)
summary(model3)


df$resid1 <- resid(model)
df$fitted1 <- fitted(model)
df$resid2 <- resid(model2)
df$fitted2 <- fitted(model2)
ggplot(data = df, aes(x = fitted2, y = resid2, col = arm)) +
  geom_point() +
  ylab("Residuals") +
  xlab("Fitted Values")
ggplot(data = df, aes(x = baseline_tempdiff, y = resid2, col = arm)) +
  geom_point() +
  ylab("Residuals") +
  xlab("Baseline Temperature Differential (°C)")
ggplot(data = df, aes(x = fitted1, y = resid1, col = arm)) +
  geom_point() +
  ylab("Residuals") +
  xlab("Baseline Temperature Differential (°C)")
ggplot(data = df, aes(x = baseline_tempdiff, y = resid1, col = arm)) +
  geom_point() +
  ylab("Residuals") +
  xlab("Baseline Temperature Differential (°C)")
# Plot them
ggplot(df, aes(x = arm, y = resid2, fill = arm)) +
  geom_boxplot() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  ylab("Residuals") +
  xlab("Arm") +
  theme_bw()

ggplot(data = df, aes(x = resid1, fill = arm)) +
  geom_histogram(bins = 20, position = "dodge") +
  xlab("Residuals")

df$weight_c <- df$weight - 75
df$age_c <- df$age - 57.5
df$base_c <- df$baseline_tempdiff - 10


adjmodel <- lm(endline_tempdiff ~ base_c * arm + sex + age_c + weight_c, data = df)
cor(df$baseline_tempdiff, df$endline_tempdiff)


wellness_model <- glm(wellness_score ~ arm + sex + age + baseline_tempdiff, data = df, family = "binomial")
summary(wellness_model)

modeltest <- lm(endline_tempdiff ~ baseline_tempdiff + sex + age + arm + weight + rmr, data = df)
vif(modeltest)

ggplot(df, aes(x = rmr, y = sex, fill = sex)) +
  geom_boxplot() +
  xlab("RMR") +
  ylab("Sex") +
  theme_bw()
ggplot(df, aes(weight, sex, fill = sex)) +
  geom_boxplot() +
  xlab("Weight") +
  ylab("Sex") +
  theme_bw()
ggplot(df, aes(age, sex, fill = sex)) +
  geom_boxplot() +
  xlab("Age") +
  ylab("Sex") +
  theme_bw()

ggplot(df, aes(baseline_tempdiff, sex, fill = sex)) +
  geom_boxplot() +
  xlab("Age") +
  ylab("Sex") +
  theme_bw()
mean(df$weight[df$sex == "F"])
mean(df$weight[df$sex == "M"])
mean(df$rmr[df$sex == "F"])
mean(df$rmr[df$sex == "M"])
mean(df$rmr)
mean(df$weight)

df_before <- df[, c("age", "weight", "rmr", "baseline_tempdiff")]
cor(df_before, use = "complete.obs")

df_part2 <- read.csv("participant_data2.csv", header = TRUE)
df_alloc2 <- read.csv("allocated2.csv", header = TRUE)
df_res3 <- read.csv("trial_results3.csv", header = TRUE)
tbl_summary(df_part2)
tbl_summary(df_alloc2)
finalised <- tbl_summary(df_res3, by = arm)
df_alloc2 <- df_alloc2[, 1:6]
df_part2 <- df_part2[, 1:6]


plot_data <- expand.grid(
  arm = c("C", "T"), # We want a line for both the Control and Treatment arms
  baseline_tempdiff = seq(min(df$baseline_tempdiff, na.rm = TRUE),
    max(df$baseline_tempdiff, na.rm = TRUE),
    length.out = 100
  ), # 100 points along the x-axis
  age = mean(df$age, na.rm = TRUE), # Hold age constant at the mean
  weight = mean(df$weight, na.rm = TRUE), # Hold weight constant at the mean
  sex = "F" # Pick one sex to visualize (make sure this matches exactly how it's spelled in your data!)
)

plot_data$predicted_endline <- predict(model2, newdata = plot_data)
library(ggplot2)

ggplot(df, aes(x = baseline_tempdiff, color = arm)) +
  # Draw the raw, messy data points from your actual trial
  geom_point(aes(y = endline_tempdiff), alpha = 0.5, size = 2) +

  # Draw the exact, straight lines generated by your model's coefficients
  geom_line(data = plot_data, aes(y = predicted_endline), size = 1.2) +

  # Make it look professional
  labs(
    title = "Model-Predicted Treatment Effect (Adjusted for Age, Weight, & Sex)",
    x = "Baseline Temperature Differential",
    y = "Endline Temperature Differential",
    color = "Trial Arm"
  ) +
  theme_bw()

simple_line_1 <- function(age, arm, baseline) {
  if (arm == "T") {
    return(0.28314 * age - 4.48057 + 0.9765 * baseline - 15.70703)
  } else {
    return(0.28314 * age + 0.9765 * baseline - 15.70703)
  }
}

plot_data <- expand.grid(
  arm = c("C", "T"), # We want a line for both the Control and Treatment arms
  baseline_tempdiff = seq(min(df$baseline_tempdiff, na.rm = TRUE),
    max(df$baseline_tempdiff, na.rm = TRUE),
    length.out = 124
  )
) # 100 points along the x-axis)


df$wellness_score <- relevel(df$wellness_score, ref = "Not improved")

# 2. Run the Logistic Regression
# Notice we use glm() instead of lm(), and add family = binomial
model_logistic <- glm(wellness_score ~ arm + baseline_tempdiff + age + sex + weight,
  data = df,
  family = binomial(link = "logit")
)

# 3. View the raw mathematical summary (Log-Odds and p-values)
summary(model_logistic)

# 4. Convert the coefficients into clinical "Odds Ratios" (OR)
# Log-odds are mathematically useful but impossible for humans to read.
# exp() translates them into plain English multipliers.
exp(coef(model_logistic))

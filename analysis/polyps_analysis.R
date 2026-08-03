# polyps data
data(polyps, package = "medicaldata")
ggplot(data = polyps, aes(x = baseline)) +
    geom_histogram()
ggplot(data = polyps, aes(x = number12m)) +
    geom_histogram()

polyps$log_baseline <- log10(polyps$baseline)
polyps$log_number12m <- log10(polyps$number12m)

polyps_df <- na.omit(polyps) # two participants (001 and 018) don't have data for 12m, so remove these
mean_T <- mean(polyps_df$log_number12m[polyps_df$treatment == "sulindac"])
sd_T <- sd(polyps_df$log_number12m[polyps_df$treatment == "sulindac"])
mean_C <- mean(polyps_df$log_number12m[polyps_df$treatment == "placebo"])
sd_C <- sd(polyps_df$log_number12m[polyps_df$treatment == "placebo"])
# There are 11 patients on Placebo (group C) and 9 on Sulindac (group T)
# The pooled standard deviation
pooled_sd_polypsX <- sqrt((10 * sd_C^2 + 8 * sd_T^2) / (10 + 8))
# Finally we find the test statistic
test_stat <- (mean_T - mean_C) / (pooled_sd_polypsX * sqrt(1 / 11 + 1 / 9))

# manual p-value
2 * pt(test_stat, df = 18)
estimate <- mean_T - mean_C
error <- qt(0.975, df = 18) * pooled_sd_polypsX * sqrt(1 / 11 + 1 / 9)
c(estimate - error, estimate + error)

# or use the built-in
t.test(
    x = polyps_df$log_number12m[polyps_df$treatment == "sulindac"],
    y = polyps_df$log_number12m[polyps_df$treatment == "placebo"],
    alternative = "two.sided",
    var.equal = T, # this makes the method use pooled variances, as we did in lectures
    conf.level = 0.95 # note that this is 1-alpha
)

# t-test for difference
polyps_df$diff <- polyps_df$number12m - polyps_df$baseline
ggplot(data = polyps_df, aes(x = diff, fill = treatment)) +
    geom_histogram(position = "dodge", bins = 10)
polyps_df$diff_log <- polyps_df$log_number12m - polyps_df$log_baseline
# outliers, non-normality, try logs
ggplot(data = polyps_df, aes(x = diff_log, fill = treatment)) +
    geom_histogram(position = "dodge", bins = 10)
t.test(
    x = polyps_df$diff_log[polyps_df$treatment == "sulindac"],
    y = polyps_df$diff_log[polyps_df$treatment == "placebo"],
    alternative = "two.sided",
    var.equal = T, # this makes the method use pooled variances, as we did in lectures
    conf.level = 0.95 # note that this is 1-alpha
)

# ancova model
lm_polyp1 <- lm(log_number12m ~ treatment + log_baseline, data = polyps_df)
summary(lm_polyp1)
vif(lm_polyp1)
c(-0.7046 - qt(0.975, df = 17) * 0.1675, -0.7046 + qt(0.975, df = 17) * 0.1675)

# include other baseline vars
lm_polyp2 <- lm(log_number12m ~ treatment + log_baseline + sex + age, data = polyps_df)
summary(lm_polyp2)

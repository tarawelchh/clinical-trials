set.seed(123)
library(car)
library(pROC)
library(ggplot2)
data <- read.csv("summative2/data/trial_results.csv")
head(data)

# Total counts and any missingness
data$arm <- factor(data$arm, levels = c("A", "B"), labels = c("C", "T"))
table(data$outcome, useNA = "always")
sum(is.na(data$outcome))
table(data$outcome, data$arm)
tapply(data$outcome, data$arm, mean)

fit_unadj <- glm(outcome ~ arm, data = data, family = binomial)
summary(fit_unadj)
exp(cbind(OR = coef(fit_unadj), confint.default(fit_unadj)))


model1 <- glm(outcome ~ Age + Sex + StressScore + baseline_STEE + arm,
  family = binomial(link = "logit"), data = data
)
summary(model1)


vif(model1)
exp(cbind(OR = coef(model1), confint.default(model1)))


par(mfrow = c(1, 1))
roc_obj <- roc(data$outcome, fitted(model1))
auc(roc_obj)

ggroc(roc_obj, legacy.axes = TRUE) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", colour = "grey50") +
  labs(
    x = "1 - Specificity",
    y = "Sensitivity "
  ) +
  theme_bw() +
  coord_equal()

# 3. Calibration plot
library(rms) # or do it manually
# Manual version:
data$pred <- fitted(model1)
data$pred_bin <- cut(data$pred, breaks = quantile(data$pred, 0:10 / 10), include.lowest = TRUE)
calib <- aggregate(cbind(outcome, pred) ~ pred_bin, data = data, mean)
plot(calib$pred, calib$outcome,
  xlim = c(0, 1), ylim = c(0, 1),
  xlab = "Predicted probability", ylab = "Observed proportion"
)
abline(0, 1, col = "red")

# 4. Residuals vs each covariate (this fixes -1 from last time)
data$resid <- residuals(model1, type = "pearson")
par(mfrow = c(2, 2))
plot(data$Age, data$resid, main = "Residuals vs Age")
abline(h = 0, col = "red")
plot(data$baseline_STEE, data$resid, main = "Residuals vs baseline_STEE")
abline(h = 0, col = "red")
boxplot(resid ~ Sex, data = data, main = "Residuals vs Sex")
boxplot(resid ~ StressScore, data = data, main = "Residuals vs StressScore")


fit_int <- glm(outcome ~ arm * (Age + Sex + StressScore + baseline_STEE),
  data = data, family = binomial
)

summary(fit_int)


prop.test(165, 256, correct = FALSE)$conf.int
# Wilson 95% CI for treatment proportion (90 of 256)
prop.test(90, 256, correct = FALSE)$conf.int

prop.test(c(90, 165), c(256, 256), correct = FALSE)


library(dplyr)
library(ggplot2)

data$StressScore <- factor(data$StressScore,
  levels = c("low", "moderate", "high")
)
# Round age into 5-year bins to get sensible group sizes
data$age5 <- round(data$Age / 5) * 5

# Compute observed proportions for each combination
data_sum <- data %>%
  group_by(age5, Sex, StressScore, arm) %>%
  summarise(
    obs = mean(outcome),
    n = length(outcome),
    .groups = "keep"
  )

# Get fitted values + SE for the same combinations (use median baseline_STEE within each group)

data_sum$baseline_STEE <- median(data$baseline_STEE)
fit_pred <- predict(model1,
  newdata = data.frame(
    Age = data_sum$age5,
    Sex = data_sum$Sex,
    StressScore = data_sum$StressScore,
    baseline_STEE = data_sum$baseline_STEE,
    arm = data_sum$arm
  ),
  se.fit = TRUE, type = "response"
)

data_sum$fit <- fit_pred$fit
data_sum$fit_se <- fit_pred$se.fit

# Plot
ggplot(data_sum, aes(x = age5, colour = arm)) +
  geom_point(aes(y = obs, size = n), pch = 16) +
  geom_point(aes(y = fit), pch = 4) +
  geom_line(aes(y = fit), linetype = "dashed") +
  coord_cartesian(xlim = c(15, 42)) +
  geom_ribbon(aes(
    ymin = fit - 1.96 * fit_se,
    ymax = fit + 1.96 * fit_se,
    fill = arm
  ), alpha = 0.3, colour = NA) +
  facet_wrap("StressScore") +
  theme_bw() +
  theme(legend.position = "bottom") +
  labs(
    x = "Age",
    y = "Probability of echo"
  )

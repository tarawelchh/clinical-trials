install.packages(c("tidyverse", "HSAUR", "HSAUR3", "pROC", "survival", "ggsurvfit", "survminer", "car"))
library(tidyr)
library(HSAUR)
library(car)
data("respiratory")
# Keep only months 0 and 4
resp_04 <- respiratory |>
    filter(month %in% c(0, 4))

## convert to wider to have one row per participant
resp_df <- pivot_wider(
    data = resp_04,
    id_cols = c("subject", "centre", "treatment", "sex", "age"),
    names_from = "month",
    names_prefix = "status",
    values_from = "status"
)

# logistic regression
model1 <- glm(status4 ~ centre + treatment + sex + age + status0,
    family = binomial(link = "logit"), data = resp_df
)
summary(model1)
vif(model1)


# remove sex and try age squared
model2 <- glm(status4 ~ centre + treatment + age + I(age^(2)) + status0,
    family = binomial(link = "logit"), data = resp_df
)
summary(model2)
# improvement ito AIC and dev

# diagnostics
library(pROC)
fit_resp <- fitted(model2) # Fitted values from model3
out_resp <- resp_df$status4 # outcome values (1 or 2)
roc_resp_df <- data.frame(fit = fit_resp, out = out_resp)
roc_resp <- roc(data = roc_resp_df, response = out, predictor = fit)
roc_resp

# confidence interval
summary(model2)
est_logOR <- summary(model2)$coefficients[3, 1]
se_logOR <- summary(model2)$coefficients[3, 2]
logOR_CI <- c(est_logOR - qnorm(0.975) * se_logOR, est_logOR + qnorm(0.975) * se_logOR)
exp(logOR_CI)

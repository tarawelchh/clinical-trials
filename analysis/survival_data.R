install.packages("survival", "ggsurvfit", "survminer")
library("survival")
library("ggsurvfit")
library("survminer")

data(cancer, package = "survival")
surv_aml <- with(data = aml, Surv(time, status))
surv_aml

# survival curve - kaplan-meier
km_aml <- survfit(surv_aml ~ x, data = aml)
summary(km_aml)

km_aml %>% ggsurvfit() +
    add_censor_mark() +
    add_risktable() +
    add_confidence_interval()

# fit an exponential distribution
mC_aml <- sum((aml$status == 1) & (aml$x == "Nonmaintained"))
mT_aml <- sum((aml$status == 1) & (aml$x == "Maintained"))
tsum_aml_C <- sum(aml$time[aml$x == "Nonmaintained"])
tsum_aml_T <- sum(aml$time[aml$x == "Maintained"])
lamhat_aml_C <- mC_aml / tsum_aml_C
lamhat_aml_T <- mT_aml / tsum_aml_T

# Define survival function for exponential density

exp_st <- function(t, lambda) {
    exp(-lambda * t)
}

km_aml %>% ggsurvfit() + ylim(0, 1) + theme_bw() +
    add_censor_mark() +
    geom_function(fun = exp_st, args = list(lambda = lamhat_aml_C), col = "darkturquoise") +
    geom_function(fun = exp_st, args = list(lambda = lamhat_aml_T), col = "red")

# likelihood ratio test
m_aml <- mT_aml + mC_aml
tsum_aml <- tsum_aml_T + tsum_aml_C
LRstat_aml <- 2 * (mC_aml * log(mC_aml / tsum_aml_C) + mT_aml * log(mT_aml / tsum_aml_T) - m_aml * log(m_aml / tsum_aml))
LRstat_aml
1 - pchisq(LRstat_aml, df = 1)

# log rank test
survdiff(surv_aml ~ x, data = aml, rho = 0)

# cox regression
cox_aml <- coxph(formula = Surv(time, status) ~ x, data = aml)
cox_aml

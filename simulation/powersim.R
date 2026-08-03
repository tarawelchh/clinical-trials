## power simulation for a t-test##
ttest_sim <- function(
  nsim, # the number of simulations to use
  N, # number of participants per trial arm
  mu, # mean outcome (for group C / under H0)
  tm, # minimum detectable effect size
  sd # sd of outcome
) {
    H0_reject_vec <- rep(NA, nsim) # to store 1 if H0 rejected, 0 if fail to reject H0
    for (i in 1:nsim) {
        # inside the loop we simulate a single trial with N in each group
        out_groupC <- rnorm(N, mean = mu, sd = sd)
        out_groupT <- rnorm(N, mean = mu + tm, sd = sd)
        ttest <- t.test(
            out_groupC, out_groupT,
            alternative = "two.sided",
            var.equal = T, conf.level = 0.95
        )
        H0_reject_vec[i] <- ifelse(ttest$p.value < 0.05, 1, 0)
    }

    power.est <- mean(H0_reject_vec)
    power.est
}

ttest_sim(100, 113, mu = 5, sigma = 8, tm = 3)

sim_vec <- rep(NA, 100)
sim_vec <- replicate(100, ttest_sim(n_sim = 100, N = 155, mu = 5, sigma = 8, tm = 3))
ggplot(mapping = aes(sim_vec)) +
    geom_histogram(bins = 10)


# modify to account for different std devs
ttest_sim2 <- function(
  n_sim, # numberofsimulations
  N, # number of participants per trial arm
  mu, # mean
  sigmaC, # standarddeviation group C
  sigmaT, # standarddeviation group T
  tm # minimum treatment effect
) {
    H0_reject_vector <- rep(NA, n_sim)
    for (i in (1:n_sim)) {
        groupC <- rnorm(N, mu, sigmaC)
        groupT <- rnorm(N, mu + tm, sigmaT)
        ttest <- t.test(groupC, groupT, alternative = "two.sided", var.equal = TRUE, conf.level = 0.95)
        H0_reject_vector[i] <- ifelse(ttest$p.value < 0.05, 1, 0)
    }
    power.est <- mean(H0_reject_vector)
    return(power.est)
}
ttest_sim2(n_sim = 100, N = 155, mu = 5, tm = 3, sigmaC = 8, sigmaT = 10)
sim_vec2 <- rep(NA, 100)
sim_vec2 <- replicate(100, ttest_sim2(n_sim = 100, N = 155, mu = 5, sigmaC = 8, sigmaT = 10, tm = 3))
ggplot(mapping = aes(sim_vec2)) +
    geom_histogram(bins = 10)

sim_vec3 <- rep(NA, 100)
sim_vec3 <- replicate(100, ttest_sim2(n_sim = 100, N = 155, mu = 5, sigmaC = 8, sigmaT = 6, tm = 3))
ggplot(mapping = aes(sim_vec3)) +
    geom_histogram(bins = 10)

# simple random sampling
one_trial_srs <- function(
  N, # number of participants per trial arm
  mu, # mean outcome (for group C / under H0)
  tm, # minimum detectable effect size
  sdC, # sd of outcome in group C
  sdT # sd of outcome in group T
) {
    ## Create empty vectors to contain output for groups C and T
    outC <- integer()
    outT <- integer()

    for (i in 1:(2 * N)) {
        # allocate using SRS
        arm <- sample(c("C", "T"), size = 1)
        # generate outcome according to groups' distributions
        if (arm == "C") {
            outi <- rnorm(1, mean = mu, sd = sdC)
            outC <- c(outC, outi)
        } else if (arm == "T") {
            outi <- rnorm(1, mean = mu + tm, sd = sdT)
            outT <- c(outT, outi)
        }
    }
    # conduct t-test for this trial
    t.test(
        x = outC, y = outT,
        alternative = "two.sided", paired = F,
        var.equal = T, conf.level = 0.95
    )
}

ttest_sim_srs <- function(
  nsim, # the number of simulations to use
  N, # number of participants per trial arm
  mu, # mean outcome (for group C / under H0)
  tm, # minimum detectable effect size
  sdC, # sd of outcome in group C
  sdT # sd of outcome in group T
) {
    H0_reject_vec <- rep(NA, nsim) # to store 1 if H0 rejected, 0 if fail to reject H0

    for (i in 1:nsim) {
        trial_i <- one_trial_srs(N, mu, tm, sdC, sdT)
        H0_reject_vec[i] <- ifelse(trial_i$p.value < 0.05, 1, 0)
    }

    power.est <- mean(H0_reject_vec)
    power.est
}

ttest_sim_srs(nsim = 100, N = 155, mu = 5, tm = 3, sdC = 8, sdT = 10)
sim_vec4 <- rep(NA, 100)
sim_vec4 <- replicate(200, ttest_sim_srs(nsim = 100, N = 155, mu = 5, tm = 3, sdC = 8, sdT = 10))
ggplot(mapping = aes(sim_vec4)) +
    geom_histogram(bins = 10)


## power simulation for ancova##
ancova_trial_srs <- function(N, mu_B, mu, rho, tm, sd_eps, sd_B) {
    trial_mat <- matrix(NA, ncol = 3, nrow = 2 * N)
    trial_df <- data.frame(trial_mat)
    names(trial_df) <- c("baseline", "arm", "outcome")
    for (i in 1:(2 * N)) {
        bas_i <- rnorm(1, mean = mu_B, sd = sd_B)
        trial_df$baseline[i] <- bas_i
        alloc_i <- sample(c("C", "T"), 1) # Using SRS in this function
        trial_df$arm[i] <- alloc_i
        eps_i <- rnorm(1, mean = 0, sd = sd_eps)
        if (alloc_i == "C") {
            out_i <- mu + rho * (bas_i - mu_B) + eps_i
        } else if (alloc_i == "T") {
            out_i <- mu + tm + rho * (bas_i - mu_B) + eps_i
        }
        trial_df$outcome[i] <- out_i
    }
    model.fit <- lm(outcome ~ baseline + arm, data = trial_df)
    summary(model.fit)
}


## Function to simulate one trial (with ANCOVA analysis)
ancova_trial_srs <- function(
  N, # Number of participants per group
  mu_B, # baseline mean
  mu, # outcome mean (control group / H_0)
  rho, # correlation between baseline and outcome
  tm, # minimum detectable effect size
  sd_eps, # SD of error
  sd_B # SD of baseline measurement
) {
    ## Empty data frame for trial data
    trial_mat <- matrix(NA, ncol = 3, nrow = 2 * N)
    trial_df <- data.frame(trial_mat)
    names(trial_df) <- c("baseline", "arm", "outcome")

    for (i in 1:(2 * N)) {
        bas_i <- rnorm(1, mean = mu_B, sd = sd_B)
        trial_df$baseline[i] <- bas_i
        alloc_i <- sample(c("C", "T"), 1) # Using SRS in this function
        trial_df$arm[i] <- alloc_i
        eps_i <- rnorm(1, mean = 0, sd = sd_eps)
        if (alloc_i == "C") {
            out_i <- mu + rho * (bas_i - mu_B) + eps_i
        } else if (alloc_i == "T") {
            out_i <- mu + tm + rho * (bas_i - mu_B) + eps_i
        }
        trial_df$outcome[i] <- out_i
    }
    model.fit <- lm(outcome ~ baseline + arm, data = trial_df)
    summary(model.fit)
}

## Function to simulate many trials (with ANCOVA analysis)

ancova_sim_srs <- function(
  nsim, # the number of simulations to use
  N, # Number of participants per group
  mu_B, # baseline mean
  mu, # outcome mean (control group / H_0)
  rho, # correlation between baseline and outcome
  tm, # minimum detectable effect size
  sd_eps, # SD of error
  sd_B # SD of baseline measurement
) {
    H0_reject_vec <- rep(NA, nsim) # to store 1 if H0 rejected, 0 if fail to reject H0

    for (i in 1:nsim) {
        trial_i <- ancova_trial_srs(N, mu_B, mu, rho, tm, sd_eps, sd_B)
        H0_reject_vec[i] <- ifelse(trial_i$coefficients[3, 4] < 0.05, 1, 0)
    }

    power.est <- mean(H0_reject_vec)
    power.est
}
sim_vec5 <- rep(NA, 100)
sim_vec5 <- replicate(100, ancova_sim_srs(nsim = 100, N = 90, mu_B = 50, mu = 60, rho = 0.65, tm = 3, sd_eps = 6, sd_B = 8))
ggplot(mapping = aes(sim_vec5)) +
    geom_histogram(bins = 10)

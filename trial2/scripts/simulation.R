set.seed(123)
power_sim_binary = function(
    nsim,  # the number of simulations to use
    N,     # number of participants per trial arm
    pi_C,  # control prob
    pi_T   # treatment prob
){
  H0_reject_vec = rep(NA, nsim) # to store 1 if H0 rejected, 0 if fail to reject H0
  for (i in 1:nsim){
    # inside the loop we simulate a single trial with N in each group
    rC = rbinom(1, size=N, prob=pi_C)
    rT = rbinom(1, size=N, prob=pi_T)
    test = prop.test(c(rT, rC), c(N, N), correct=FALSE)
    H0_reject_vec[i] = ifelse(test$p.value < 0.05, 1, 0)
  }
  
  power.est = mean(H0_reject_vec)
  power.est
}

#power_sim_binary(nsim=10000, N=230, pi_C=0.6, pi_T=0.45)

# Set parameters
pi_C = 0.6
pi_T = 0.45
nsim = 10000

# Try a range of N values
N_vec = seq(100, 300, by=5)
power_vec = rep(NA, length(N_vec))

for (j in 1:length(N_vec)){
  power_vec[j] = power_sim_binary(nsim=nsim, N=N_vec[j], pi_C=pi_C, pi_T=pi_T)
  cat("N =", N_vec[j], "  power =", round(power_vec[j], 3), "\n")
}

# Find smallest N with power >= 0.9
N_min = min(N_vec[power_vec >= 0.9])
N_min

power_vec
N_vec
power_curve <- data.frame(N=N_vec, P=power_vec)

### power curve####
ggplot(data=power_curve)+
  geom_point(aes(x=N, y=P))+
  geom_line(aes(x=N, y=P), linetype = "solid", linewidth = 0.4, alpha = 0.6) +
  geom_hline(yintercept=0.9, col="red", linetype="dashed")+
  scale_x_continuous(breaks = seq(100, 300, by = 20)) +
  labs(
    x = "N (Sample Size per Arm)",
    y = expression("Empirical Power ")
  ) +
  theme_minimal()

N_vec_2 = seq(235, 240, by=1)
power_vec_2 = rep(NA, length(N_vec_2))

for (j in 1:length(N_vec_2)){
  power_vec_2[j] = power_sim_binary(nsim=nsim, N=N_vec_2[j], pi_C=pi_C, pi_T=pi_T)
  cat("N =", N_vec_2[j], "  power =", round(power_vec_2[j], 3), "\n")
}


sim_vec1 = rep(NA, 200)
for (i in 1:200){
  sim_vec1[i] = power_sim_binary(nsim=10000, N=235, pi_C=0.6, pi_T=0.45)
}
require(ggplot2)
ggplot(mapping = aes(sim_vec1))+
  geom_histogram(bins=10)+
  labs(x="Power", y="Trial Count")+
  geom_vline(xintercept=0.9, col="red", linetype="dashed")+
  theme_minimal()


sim_vec2 = rep(NA, 200)
for (i in 1:200){
  sim_vec2[i] = power_sim_binary(nsim=10000, N=235, pi_C=0.55, pi_T=0.45)
}
ggplot(mapping = aes(sim_vec2))+
  geom_histogram(bins=10)+
  labs(x="Power", y="Trial Count")+
  geom_vline(xintercept=0.9, col="red", linetype="dashed")+
  theme_minimal()


sim_vec3 = rep(NA, 200)
for (i in 1:200){
  sim_vec3[i] = power_sim_binary(nsim=10000, N=235, pi_C=0.65, pi_T=0.45)
}
ggplot(mapping = aes(sim_vec2))+
  geom_histogram(bins=10)+
  labs(x="Power", y="Trial Count")+
  geom_vline(xintercept=0.9, col="red", linetype="dashed")+
  theme_minimal()

# Type I error check: simulate under H0 (pi_T = pi_C)
type1_check = power_sim_binary(nsim = 100000, N = 235, pi_C = 0.6, pi_T = 0.6)
type1_check

sim_vec2 = rep(NA, 100)
for (i in 1:100){
  sim_vec2[i] = ttest_sim(nsim=100, N=155, mu=5, tm=3, sd=8)
}
ggplot(mapping = aes(sim_vec2)) + geom_histogram(bins=10)

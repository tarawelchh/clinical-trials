# Clinical Trials

End-to-end design, simulation, allocation, and statistical evaluation of randomized controlled trials (RCTs) across continuous and binary endpoints. Methodology and analysis for two clinical trials in [`trial1/report.pdf`](https://github.com/tarawelchh/clinical_trials/blob/main/trial1/report.pdf) and [`trial2/report.pdf`](https://github.com/tarawelchh/clinical_trials/blob/main/trial2/report.pdf).

## Trial 1 

### Overview

This trial is based on Ventrothermal Drift, a fictional condition in which sufferers tend to overestimate their torso temperature.
Sufferers can feel very lethargic and generally unwell. The primary outcome variable is the temperature differential as this is the primary symptom of the condition. 

### Trial Design and Allocation 
We test the following hypotheses regarding the treatment effect, $\tau$:$H_0: \tau = 0$$H_1: \tau \neq 0$.
A sample size of 62 participants per arm was calculated to ensure 90% power, accounting for both the correlation between baseline and endline temperature differential measurements and potential trial attrition.For allocation, trial arms were stratified based on sex, and randomly permuted blocks were used to assign participants. This method resulted in no meaningful imbalance across the 5 recorded baseline characteristics.

### Analysis
Variance Inflation Factor (VIF) scores were calculated for all variables. Covariates with a VIF score greater than 3 were removed to prevent multicollinearity, with the exception of sex, as it was the stratification variable.

An ANCOVA model was applied to adjust for all remaining covariates without initial interaction terms. This resulted in the following linear model:
$$\delta_{\text{endline,i}} = \beta_0 + \tau G_i + \beta_1 \delta_{\text{baseline,i}} + \beta_2 a_i + \beta_3 s_i + \beta_4 w_i + \varepsilon_i$$
Where:
* $\varepsilon_i$ is modeled as i.i.d normal.
* $\delta$ represents the temperature differential.
* $G_i$ is an indicator variable where $G_i=1$ for participants in the treatment arm (T) and $G_i=0$ for the control arm (C).
* $a_i$, $s_i$, and $w_i$ represent age, sex (0 for female, 1 for male), and weight respectively.
* $\beta_i \in \mathbb{R}$ are the estimated coefficients of the model.$i = 1, ..., 124$ represents the trial participants.
  
Secondary analysis was performed using a logistic model to model wellness score. 


### Key Findings
The primary ANCOVA analysis yielded a 95% confidence interval for the treatment effect $\tau$ : 
$-4.481 \pm t_{0.975;118} \times 0.8287 = [-6.12, -2.84]$ . 
Because the confidence interval does not contain zero, we reject the null hypothesis $H_0$, concluding a statistically significant treatment effect.

## Trial 2

### Overview
This trial concerns patients who have recently been diagnosed with a fictional condition called Spontaneous Temporal Echo Episodes
(STEE), causing patients to experience ‘echoes’ which are involuntary and disorienting, and can cause psychological
distress and social disruption. The treatment offered to the intervention group is Chronquel (TM), which has been developed to stabilize
chronosynaptic firing. The control group will be given a placebo. The primary outcome variable is whether
a participant has had any ‘echoes’ within 10 days of starting the trial. The control probability for this is
estimated to be around $\pi_C = 0.6$.

### Trial Design and Allocation 
We test the following hypotheses regarding the probability of a patient experiencing an echo within 10 days of starting the trial, $H_0: \pi_T = \pi_C$, $H_1: \pi_T \neq \pi_C$.

Sample size is selected via Monte Carlo simulation of a two-sided chi-squared test. Participants are allocated arms sequentially via minimisation.

<img width="700" alt="Screenshot 2026-09-22 at 18 49 26" src="https://github.com/user-attachments/assets/d9b5d282-101b-44b7-b4cd-5dc244f3abcb" />


### Analysis

Logistic regression is employed, adjusting for all covariates. This results in the following model:
$$Y_i | \mathbf{x_i} \overset{indep.}{\tilde} Bernoulli(p_i)$$
$$\log \left( \frac{p_i}{1-p_i} \right) = \beta_0 + \beta_T G_i + \mathbf{\beta}^\top \mathbf{x_i}$$

### Key Findings

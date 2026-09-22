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

$$Y_i | \mathbf{x_i} \overset{indep.}{\sim} Bernoulli(p_i)$$
$$\log \left( \frac{p_i}{1-p_i} \right) = \beta_0 + \beta_T G_i + \mathbf{\beta}^\top \mathbf{x_i}$$
where :
* $G_i$ is an indicator variable where $G_i=1$ for participants in the treatment arm (T) and $G_i=0$ for the control arm (C).
* Other covariates are represented by the vector $mathbf{x_i}$ with coefficients $\mathbf{\beta}$

We consider the odds ratio of the logistic regression model as well as the number needed to treat, absolute risk difference and risk ratio. Wilson confidence intervals are used as they produce asymmetric intervals with better coverage and are bounded between 0 and 1. 

Diagnostics are presented, including a ROC curve and calibration.

<img width="700"  alt="Screenshot 2026-09-22 at 18 59 59" src="https://github.com/user-attachments/assets/4b682e6a-059d-412e-af0c-9195ed621492" />

<img width="700" alt="Screenshot 2026-09-22 at 19 00 12" src="https://github.com/user-attachments/assets/d6eeea21-1e5f-4a29-acd4-d1d29cadd5ab" />

### Key Findings
The results of the primary analysis, covariate-adjusted logistic regression, indicated that the treatment
Chronquel reduces probability of echoes in participants with STEE. 
* The p-value was 1.08 × 10−11 and so the null hypothesis was strongly rejected.
* The odds ratio was 0.259, so that the odds were reduced to 26%
of those of the control arm.
* We considered the simpler logistic regression without adjusting for covariates,
from which we obtain sample proportions as probability estimates, with $p_C = 0.645$ and $p_T = 0.352$ for the
control and treatment arms respectively.
* 45.4% risk reduction of an echo
in the treatment group when compared with the control.
* The control group proportion was estimated
to be 0.6 and was observed as 0.645 - indicative of a well-calibrated trial.

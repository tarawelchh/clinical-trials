# Clinical Trials

End-to-end design, simulation, allocation, and statistical evaluation of randomized controlled trials (RCTs) across continuous and binary endpoints. Methodology and analysis for two clinical trials in [`trial1/report.pdf`](https://github.com/tarawelchh/clinical_trials/blob/main/trial1/report.pdf) and [`trial2/report.pdf`](https://github.com/tarawelchh/clinical_trials/blob/main/trial2/report.pdf).

## Trial 1 

### Overview
This trial is based on Ventrothermal Drift, a fictional condition in which sufferers tend to overestimate their torso temperature.
Sufferers can feel very lethargic and generally unwell. The primary outcome variable is the temperature differential as this is the primary symptom of the condition. 

### Trial Design and Allocation 
We test the hypotheses:
$\mathcal{H}_0 : \tau = 0 \\ \mathcal{H}_1 : \tau \neq 0 $
where $\tau$ represents the treatment effect. 

* A sample size of 62 participants per arm is calculated to ensure a power of 90%, after incorporating the correlation between baseline and endline temperature differential measurements and also accounting for potential attrition.
* For allocation, trial arms are stratified based on sex and randomly permuted blocks are used to allocate participants. This resulted in no meaningful imbalance among the 5 recorded characteristics. 

### Analysis
* The VIF is calculated and covariates with VIF score greater than 3 are removed (other than sex as this was used for stratification).
* An ANCOVA model is used, adjusting for all remaining covariates. No interaction terms are introduced. This results in a linear model of the form:
$ \delta_{\text{endline,i}} = \beta_0 + \tau G_i + \beta_1 \delta_{\text{baseline,i}} + \beta_2 a_i + \beta_3 s_i + \beta_4 w_i + \varepsilon_i,$
where $\varepsilon$ is modelled as i.i.d normal, $\delta$ represents the temperature differential, $G_i$ is an indicator variable with $G_i =1$ for participants in arm T and $G_i =0$ for those in arm C. Terms $a$, $s$, and
$w$ represent the covariates age, sex and weight respectively, with $s$ a factor (0 for female and 1 for male).
$\beta_i \in \mathbb{R}$ are the coeffcients of the linear model which we are estimating and $i = 1, . . . 124$ represent the
participants of the trial.
* Further interaction terms are introduced and secondary analysis is performed using a logistic model. 


### Key Findings
* The primary analysis results in a 95% confidence interval for the treatment effect $\tau$ as $-4.481 \pm t_{0.975;118} \times 0.8287 =[-6.12,-2.84]$, not containing zero so the null hypothesis is rejected.


## Trial 2

### Overview

### Trial Design and Allocation 

### Analysis

### Key Findings

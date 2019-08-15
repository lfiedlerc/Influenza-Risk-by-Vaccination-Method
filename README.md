# Influenza Risk by Vaccination Method
Influenza is a seasonal disease that in the United States presents mainly during the winter months and can potentially cause severe illness and sometimes even death. Given the significant public health burden that influenza poses, this analysis will evaluate whether there is any significant difference in the protections provided to children by the injected vaccine compared to the nasal spray known as FluMist.

## Objective
This analysis explores whether, for children in the United States during 2012, there were any significant differences in the protection against influenza provided by the injected vaccine compared to the nasal spray known as FluMist. Furthermore, the analysis evaluated whether any effect modification due to age was present.

## Statistical Methods
To compare the effectiveness of the two influenza vaccine options in children, a case-control study was conducted by sampling records from the 2012 National Health Interview Survey. A univariate analysis was conducted to compare the characteristics of cases and controls. Statistical differences between cases and controls were evaluated using a Chi-square test with an alpha of 0.05.

Multivariate analysis was done by building a logistic regression model to describe the relationship between the vaccination method and the prevalence of influenza. The model was adjusted to control for sex, age, race, presence other children or elderly in the household, and indicators of long-term poor health as measured by proxy through the number of schools days missed.

To assess whether the effect of vaccination method on influenza varies by age group, an interaction term between age and vaccination method was added to the model. This analysis is presented separately.

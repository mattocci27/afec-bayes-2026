# AFEC 2026: course restructuring plan (agreed direction)

Updated 2026-10-16; subsequent Day 2 decisions are recorded in Section 4.

This proposal reflects the agreed direction: prioritize concepts, figure
interpretation and connections to research. Day 1 has one practical activity,
Day 2 uses CNDD as its main example, and Day 3 develops understanding through
mother trees before connecting to research examples. Reading supplied Stan
models and results is the common goal. Revise each day's slides and activities,
the instructor schedule, participant versions without solutions, and offline
result sheets accordingly.

## 1. Teaching priorities to restore

The audience is ecologists who do not specialize in statistics. The course
should help them understand why Bayesian inference and hierarchical models are
useful through ecological questions and figures, providing a starting point for
their own research.

The original `main.qmd` includes using Stan and R among its objectives, but its
instructor notes say “coding exercises are not the focus” and “idea of Bayesian
in ecology.” Restore that emphasis.

Use `main.qmd` as the reference for depth and teaching approach. Across the three
days, connect likelihood and seedlings, ecological motivation for hierarchical
models, familiar examples of Bayes, the role of priors, and a return to
hierarchical models through mother trees. Do not make learning diagnostic
terminology or implementation procedures the new focus.

Keep short equations that correspond to the figures, using a consistent order:

**Familiar example or ecological question → predict → inspect a figure → explain
with the necessary equations → interpret ecologically.**

Participants need not calculate or implement everything introduced during class.
Show Stan code to make the model concrete. The common goal is to identify data,
unknowns and assumptions in supplied code with the instructor, and to interpret
resulting figures. Editing and implementation are optional extensions.

## 2. Assumptions and overview

These are design assumptions, some still awaiting confirmation.

- Three 90-minute sessions for approximately 30 participants.
- Do not assume R experience or knowledge of GLMs. Supplied code and supplied
  figures provide routes to the same comparisons and interpretations.
- The October 15 timetable assigns 50 minutes on October 20 to checking R and
  seven daytime hours on October 21–26 to R and statistics. This course occupies
  the evenings of the first three days. As daily content is unknown, explain
  necessary regression and probability concepts through figures. Allow for
  fatigue; new inference by every participant is not required.
- Do not assume prior Bayesian experience. Briefly explain logarithms,
  probability and regression as needed.
- Instruction and participant materials are in English. This instructor-facing
  plan is also available in English.
- Allow discussion in pairs and design activities for one instructor.
- No required homework is proposed; extension materials remain available later.
- The initial proposal uses a browser environment with prechecked local use as
  an alternative. The final computing arrangement is a separate decision.

| Day | Central question | Intended outcome | Participant activity |
|---|---|---|---|
| Day 1 | How do our beliefs change after seeing data? | Explain prior, likelihood, posterior and the effect of sample size through figures and words | One short figure-comparison activity |
| Day 2 | How does seedling survival change with conspecific density? | Explain survival probabilities and uncertainty at low and high densities; compare the model with observations | One activity reading CNDD results with supplied code |
| Day 3 | How can we handle species or mother trees with little data? | Explain partial pooling and why it is useful in research | One comparison of mother-tree estimates |

Connect the sessions as estimating seedling survival, estimating its change with
density, and estimating mother-tree/species differences while sharing
information. Here, CNDD (conspecific negative density dependence) means lower
seedling survival at higher conspecific density. Connect this to the research
example introduced as NDD in `main.qmd`.

Reduce the number of activities while retaining participation: ask for
predictions before revealing results, explanations to a neighbour and brief
whole-class responses.

## 3. Day 1: becoming familiar with Bayesian reasoning

### Explanation sequence

1. **Ecological starting point:** estimate seedling survival. With two survivors
   out of five, what can we say, and what remains uncertain? Briefly show CNDD
   and species differences as the destination of the course.
2. **Likelihood:** use the original Normal figures to ask how plausible these
   data are for a particular parameter. Hold data fixed and vary the parameter.
   Return to seedlings: the estimate 2/5 alone does not describe uncertainty.
3. **Forward and inverse problems:** use conditional probability, `fip_1` through
   `fip_6`, and PCR. Distinguish predicting outcomes from known conditions from
   reasoning about unknown conditions after observing outcomes.
4. **Bayes' theorem:** connect posterior ∝ likelihood × prior to the examples.
   Do not require derivation or memorization of notation.
5. **Coin tosses and seedlings:** show how the same prior has different effects
   with different amounts of data. Compare 3/5 and 60/100, holding the observed
   proportion fixed. Explicitly connect heads and seedling survivors through
   the same binomial model.
6. **Short activity:** compare seedling figures and describe changes in words.
7. **Introduction to Stan:** show code and supplied results for the same
   seedling model. Present Stan as a tool for approximating the posterior with
   samples. Identify data, unknowns and assumptions in code and connect them
   to a plot of posterior samples.

### Proposed 90-minute schedule

| Time | Content |
|---|---|
| 0–8 min | Connection check, course destination and seedling question |
| 8–23 min | Likelihood figures, seedling estimation and uncertainty |
| 23–43 min | Conditional probability, forward/inverse problems, PCR and Bayes' theorem |
| 43–58 min | Priors and posteriors, coin comparison and connection to seedlings |
| 58–70 min | Figure-comparison activity: 8 minutes of discussion/work and 4 minutes of explanation |
| 70–80 min | Instructor demonstration of Stan and posterior samples |
| 80–85 min | Participants recap the day's ideas in their own words |
| 85–90 min | Questions and buffer |

Times are planning estimates. The forward/inverse problem image sequence
reveals an explanation step by step; do not treat every image as a separate
concept requiring a lengthy explanation.

### Proposed activity: how do figures change with data or priors?

- **Purpose and duration:** explain the roles of prior and data in one's own
  words. Use one activity with 8 minutes for predictions, code and discussion,
  followed by 4 minutes of explanation.
- **Starter:** supply this completed code in the prepared environment. Do not
  require filling blanks or writing plotting code.

```r
plot_update(2, 5, 1, 1)
plot_update(40, 100, 1, 1)
plot_update(2, 5, 8, 2)
```

- **Question 1:** the first two plots hold the prior and observed proportion 0.4
  fixed and change only sample size. Which posterior should be narrower?
- **Question 2:** the first and third plots hold the data at 2/5 and change the
  prior. In which direction does the posterior move?
- **Response:** one sentence about each observation. Running code alone is not
  the completion criterion.
- **Expected observations:** more data give a narrower posterior in this
  comparison. With data fixed at 2/5, the Beta(8,2) prior moves the posterior
  toward higher survival probabilities.
- **Instructor explanation:** the first comparison isolates sample size; the
  second isolates the prior. Check misconceptions that the posterior peak
  always equals the observed proportion or that a prior always has the same
  influence. Priors need ecological justification: ask whether expecting high
  survival is reasonable in this habitat.

**Keep in the main sequence:** intuitive Normal figures, seedlings, conditional
probability, `fip`, PCR, coin tosses and posterior figures.

**Candidates for optional reference:** MLE differentiation, numerical Beta-update
practice, comparisons of MLE/MAP/posterior mean, detailed Stan-block reading,
posterior probability calculations, posterior predictions for 50 new
individuals, and MH/HMC mechanics.

Label the coin-toss posterior peak as MAP, distinct from posterior mean or MLE.
Calculations belong in instructor notes. Beta(51,51) is deliberately strong and
still matters after 100 observations; do not present it as a recommended default.

**If running late:** shorten the Stan demonstration and preserve activity
explanation and final questions. Do not fill time with an additional MCMC lesson.

## 4. Day 2: Linear regression and MCMC

**Update, 2026-10-19:** replace the earlier 15-minute comparison below with a
20-minute regression-results walkthrough. Use completed standard R code to
follow the coefficient table, numerical diagnostics, traces and regression
curve; do not hide processing in custom functions. This revision assigned
40–60 minutes to the activity/explanation and 60–70 minutes to prediction/PPC,
using supplied fits and interpreting low/high density in the regression plot.

**Update, 2026-10-20:** PPC and predictions of survivor counts for a new group
are now optional reference. Remove the general ecological-interpretation slide
and “Your research question.” After the walkthrough, retain only a brief preview
of tomorrow and questions. Keep the sentence that sampling diagnostics do not
establish ecological model appropriateness. Use remaining time for questions
and different working speeds.

**Further update, same day:** follow the root `exercise.qmd` style: code,
output, then explanation. Remove Time, Questions and response blanks from the
Day 2 student material. Use an instructor-led explanation of standard R code,
without separate timed tasks or an answer-checking session. For the current
detailed sequence and explanations, see `classroom/instructor.md` and
`day2/exercise.qmd`. The earlier proposal below is retained as design history;
do not restore its extra activities or lengthy instructions to the student copy.

The main example is binomial logistic regression for CNDD. Keep the seedling
survival context from Day 1 while moving from a single survival probability to
one that changes with density. Day 2 covers a single shared survival curve;
species-specific density effects lead into the Day 3 instructor demonstration.
Allometry is a separate Day 3 research example; its analysis activity belongs
in extension material.

### Explanation sequence in the earlier proposal

1. **Question and prediction:** “Are seedlings less likely to survive where
   conspecific neighbours are more numerous?” Predict from a scatterplot of
   density and observed survival proportions. Show seedling counts per point.
2. **From Day 1 to the model:** survivor counts remain binomial, but survival
   probability changes with density across quadrats. Use the existing simulated
   data for 60 quadrats.
3. **Logit and prior scale:** connect a probability curve constrained to 0–1
   with a straight line on the logit scale. Introduce prior scale using the
   Normal-regression figure from `main.qmd`: is a slope of 100 extreme given
   the units and ranges of x and y? Return to CNDD and explain that the same
   numerical prior SD means something different on the logit scale and should
   be examined on the probability scale. Keep the Normal example to about
   three minutes of explanation, without another fit or activity. Logit
   derivation, odds-ratio calculations and detailed CNDD prior-curve comparisons
   are optional reference.
4. **Estimation and computational checks:** connect the supplied Stan model
   with stored results. Check diagnostics before interpreting the survival
   curve and its uncertainty; do not stop at coefficient values.
5. **Prediction and a short activity:** compare survival probabilities and
   intervals at low and high density. Distinguish uncertainty about probability
   from variation in survivor counts for a new seedling group.
6. **Model checks:** hold observed densities and seedling counts fixed and
   simulate survivor counts from the posterior. Compare density patterns and
   between-quadrat variability with observations. Discuss where the figure
   disagrees with the data.
7. **Interpretation and connection to Day 3:** do not infer causation from a
   density association alone. Consider light, other conditions and species
   differences before moving to differences among groups tomorrow.

Use equations that correspond to the figures. Let i index quadrats, s_i be
survivors, n_i be seedlings and x_i be scaled conspecific density.

$$
s_i \sim \operatorname{Binomial}(n_i, p_i), \qquad
\operatorname{logit}(p_i) = \alpha + \beta x_i.
$$

Match `stan/logit_reg.stan`: independent Normal priors with mean 0 and SD 2.5
for alpha and beta. Negative beta means survival probability decreases with
density; beta itself is not a difference in probabilities. Interpret results
back on the probability scale.

The binomial model assumes seedlings within a quadrat share a survival
probability and survive independently conditional on that probability. Assess
this assumption and the use of density alone through model checks and ecological
knowledge.

### Earlier proposed 90-minute schedule

| Time | Content |
|---|---|
| 0–10 min | Day 1 recap, CNDD question and predictions |
| 10–25 min | From the binomial model to density-dependent survival; logit and Normal-regression prior-scale figures |
| 25–40 min | Supplied model and results, computational checks, probabilities and predictions |
| 40–55 min | Low/high-density activity: 10 minutes of discussion/work and 5 minutes of explanation |
| 55–70 min | Instructor demonstration comparing observed and model-generated survivor counts/proportions |
| 70–80 min | Interpretation, species differences and connection to Day 3 |
| 80–85 min | Discuss what participants would predict or check in their research |
| 85–90 min | Questions and buffer |

### Earlier activity: how different are low- and high-density survival probabilities?

- **Purpose and duration:** explain survival differences and uncertainty in
  ecological terms; 10 minutes of prediction/work/discussion and 5 minutes of
  explanation.
- **Starter proposal:** use the CNDD section of `day2/exercise.qmd`,
  `make_ndd_data()`, `stan/logit_reg.stan` and the matching stored `day2_ndd` fit.
  Supply short completed blocks for data preparation, loading and plotting.
  Transform each posterior sample with `plogis(alpha + beta * x)` to show the
  curve and low/high-density intervals. Do not require writing Stan data lists
  or plotting code. Supplied figures provide the same comparison.
- **Fixed conditions:** hold data, model, priors and posterior samples fixed.
  Change only prediction density: x=-1 (one SD below the reference mean) and
  x=1 (one SD above). Do not refit.
- **Steps:** predict which probability is higher, display the curve and 95%
  intervals, read probabilities at both densities, then write values, intervals
  and one sentence of interpretation.
- **Questions:** how do probabilities differ between low and high density?
  Does knowing the probability determine the next group's survivor count?
- **Expected observations:** survival probability decreases with density in
  these teaching data, with uncertainty. Future counts vary even at the same
  density. Read values from the matching stored results and distinguish them
  from published research estimates.
- **Instructor explanation:** beta is neither an absolute nor a percentage
  reduction in survival probability. Calculate probability intervals after
  transforming each posterior draw. Explain prediction using survivor counts
  for 20 new seedlings at each density and distinguish their variation from
  probability intervals. Do not infer causation from a density association.

**Earlier model-check demonstration:** hold the original x_i and n_i fixed,
then draw replicated survivor counts from the binomial model for every posterior
sample. Use separate figures for uncertainty in the probability curve and
variation in generated survival proportions. Check density patterns and overall
variation; agreement in one figure is insufficient. These data were simulated
from the model, so do not promise a discrepancy. Agreement does not demonstrate
CNDD in a real forest.

**Main content in the earlier proposal:** the CNDD question, the binomial model
shared with Day 1, probability curves and logit, priors and variable scale,
survival probabilities and intervals, simple model checks and the need to
inspect computational warnings.

**Candidates for optional reference in the earlier proposal:** allometry
analysis, logit derivation and odds ratios, prior-predictive implementation,
repairing a failed model, calculating diagnostics or memorizing thresholds,
and comparisons with brms or new inference. The earlier brms plan was a
precomputed instructor demonstration of at most three minutes, or optional work
in a prepared environment, outside homework and basic package requirements.
A posterior distribution of the probability difference is an extension:
calculate p(1)-p(-1) for each paired draw from the same posterior.

Briefly introduce what R-hat, ESS and divergences help check. Encourage attention
to both computational reliability and whether the ecological model explains
the data. The instructor should continue using multiple diagnostics and model
checks; simplifying student material is not a reason to omit validation.

**Earlier contingency if running late:** shorten Stan-code explanation and the
species preview; use concise diagnostic explanations and supplied material.
Preserve the low/high-density comparison, model checks and activity explanation.
The updates at the start of this section supersede this earlier contingency.

## 5. Day 3: Hierarchical models

### Explanation sequence

1. **Question:** mother trees differ in seedling numbers and survival. Should
   we trust 0% or 100% survival based on very few seedlings?
2. **Two extremes:** compare one shared survival probability with completely
   separate estimation for each mother tree.
3. **Partial pooling:** allow differences while using shared information.
   Return to Day 1 priors and show that the centre and spread of the distribution
   describing similarities among mother trees are also estimated from data.
   Use the group-spread figures from `main.qmd` to show changes in information
   sharing.
4. **Short activity:** predict which estimates move, then compare with plots.
5. **Research connections, instructor demonstration:** extend Day 2's shared
   survival curve to species. Use `main.qmd` to show two levels: individual
   survival versus conspecific density, then species density effects versus
   abundance. Species plots are conceptual simulations; do not add a new
   species-level CNDD fitting activity. Next show a separate research example:
   DBH versus height, then species slopes versus wood density. Put allometric
   log transformations and coefficient calculations in extension material;
   emphasize the shared hierarchical structure.
6. **Participants' research:** discuss possible groups and differences of interest.

### Proposed 90-minute schedule

| Time | Content |
|---|---|
| 0–10 min | Revisit Day 2's survival curve and introduce the mother-tree question |
| 10–25 min | Compare shared and separate estimates through figures |
| 25–40 min | Meaning of partial pooling and why estimates move |
| 40–55 min | Mother-tree activity: 10 minutes of discussion/work and 5 minutes of explanation |
| 55–70 min | Instructor demonstration: species CNDD, 10 minutes; allometry/wood-density research example, 5 minutes |
| 70–80 min | Model assumptions, limitations and research applications |
| 80–85 min | Three-day recap |
| 85–90 min | Questions and buffer |

The mother-tree activity uses different simulated data from Day 2 and no density
predictor, focusing on differences among mother trees. Both examples use a
binomial survival model, but mother trees and species are different grouping
units; the research demonstration considers species-specific density effects.
Allometry uses a continuous observation model while sharing the same idea of
information sharing across groups.

### Proposed activity: which mother-tree estimates move, and in which direction?

- **Purpose and duration:** connect changes caused by information sharing to
  mother-tree data; 10 minutes of predictions/work/discussion and 5 minutes of
  explanation.
- **Starter proposal:** supply the three comparison plots from
  `day3/exercise.qmd` and code to display them from stored results. Do not require
  implementing three models. Supplied figures allow the same comparison.
- **Steps:** examine seedling counts and survival proportions, choose two mother
  trees whose estimates may move and explain why, display results, then discuss
  differences from predictions.
- **Expected observations:** estimates for trees with less data are more
  sensitive to shared information. When the model estimates large differences
  among groups, sharing has less influence.
- **Instructor explanation:** partial pooling does not guarantee a smaller
  error for every mother tree. Estimates do not all shift uniformly toward
  overall observed survival; movement depends on each tree's information and
  between-group variation. Consider whether similarity among trees is an
  ecologically reasonable assumption.

**Keep in the main sequence:** the original mother-tree example, comparison of
three estimates, group-spread figures, meaning of information sharing and
connections to the research examples. For CNDD and wood density, show the
question, figure, two model levels and what can be learned in research.

**Candidates for optional reference:** separate varying-intercept/slope
implementation activities, hierarchical-SD calculations, predictions for new
mother trees or species, covariance/Cholesky/LKJ, non-centering details and
software comparisons.

**If running late:** shorten research-model equations and code; show the
allometry/wood-density example through supplied figures. Preserve the
mother-tree comparison and the connection from Day 2 CNDD to species differences.

## 6. Use of existing materials

| Content | Treatment in this plan |
|---|---|
| Familiar explanations and figures in `main.qmd` | Prioritize them as entry points |
| `fip_1`–`fip_6`, PCR and coin tosses | Keep in Day 1; no separate calculation activities |
| Normal and seedling likelihood examples | Retain and explain distribution differences; detailed log-likelihoods and differentiation are optional |
| Existing detailed required tasks | Preserve them, then assign to demonstrations, optional tasks or reference |
| CNDD binomial logistic regression | Main Day 2 example; use existing data and matching stored fits to complete estimation, interpretation and checking |
| Allometry analysis activity | Extension material; introduce it with wood density as a separate Day 3 research example |
| Motivation from mother trees, species differences and NDD | Start with field questions; understand the mechanism through mother trees, then connect species CNDD and wood density to research |
| Published research questions and teaching data | Distinguish actual research from teaching simulations |
| Stan models, data and stored fits | Reuse existing resources; read complete models and results; editing and implementation are optional |
| Detailed explanations and diagnostics | Keep in instructor/extension material; show what is needed for understanding in the main sequence |

## 7. Preparation and delivery

- Check connectivity and figure display before class. Installation or compilation
  during class is not required.
- Ensure participants without working code can address the same questions using
  supplied figures and tables.
- Required activities use supplied results or lightweight calculations. Choose
  new-inference demonstrations after checking environment and timing.
- Match Day 2 CNDD data to their fit. Prepare low/high-density probability plots,
  diagnostics and model-check figures. Seed any additional predictive simulation
  and supply figures for offline participation.
- Separate participant instructions for prediction, execution and interpretation
  from instructor explanations, figure-reading guidance and common misconceptions.
  Implementation tasks belong in optional material. Follow the current Day 2
  walkthrough decisions above rather than restoring its earlier worksheet.
- Pacing has not been measured. Adjust after testing on actual machines and
  rehearsing the explanations.
- Do not add extensions to the 90-minute core. Offer them after class or to
  participants who have completed the essentials.

## 8. Agreed direction and remaining decisions

| Item | Direction | Status |
|---|---|---|
| Learning goals | Prioritize concepts, figure interpretation and research connections; use `main.qmd` for depth and approach | Agreed |
| Day 1 | Retain fip, PCR and coin tosses; one practical activity | Agreed |
| Day 2 | CNDD binomial logistic regression; read survival probabilities and checks; allometry analysis is extension material; current scope is defined by the Section 4 updates | Agreed |
| Day 3 | Understand through mother trees; instructor connects species CNDD and allometry/wood density to research | Agreed |
| Stan | Read supplied models and results; editing and implementation are optional | Agreed |

Remaining design questions concern alignment with the daytime statistics
programme, teaching language, homework and participant computing arrangements.
Current assumptions are listed in Section 2.

The corresponding materials are `dayN/slides.qmd`, instructor exercises with
solutions in `dayN/exercise.qmd`, generated `dayN/exercise-student.qmd`, and offline
results in `dayN/results.qmd`. Keep the schedule in `classroom/instructor.md` and
distribution in `dist/afec-classroom-materials.zip`. Day 2 is centred on CNDD,
a short Normal-regression prior-scale explanation and a guided regression
walkthrough; PPC remains optional under the latest decisions.

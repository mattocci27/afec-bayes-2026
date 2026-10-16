# 2026-10-16 handoff: Day 1 likelihood and posterior figures

Follows `2026-10-16-cndd-course-day1-handoff.md`. This log supersedes its
description of PCR as core Day 1 content and its rescaled Normal likelihood curve.

## Goal

Make the Day 1 slides easier to follow for ecology graduate students with limited
statistical confidence. Connect ecological observations, likelihood, prior and
posterior through figures, with short English explanations. Preserve the existing
theme and slide dimensions. Instructor communication remains Japanese.

## Current decisions and changes

### Normal and Binomial likelihoods

- The first Normal slide now pairs the general notation
  `f(data | parameters)` with the example `Normal(x_i | mu, sigma)`. Sigma is the
  standard deviation. The redundant sentence stating mean 0 and SD 1 was removed;
  those values are already on the figure.
- The next slide explicitly connects changing mu to changing the density heights
  and their product. That product, viewed as a function of mu with observations
  and sigma fixed, is the likelihood. Its equation was moved below the columns
  to prevent horizontal overflow.
- The explicit three-term R log-density comparison remains in the main sequence.
- The seedling Binomial equation uses `Binomial(2 | 5, p)`. Five is the known,
  fixed trial count; only p is inferred. The conditioning side can include known
  quantities. Do not restore the intermediate `B(2,5 | p)` notation.

Final plotting choices are deliberately different across examples:

| Figure | Vertical scale |
|---|---|
| Normal curve as a function of mu | Unshifted log-likelihood |
| Binomial MLE, 2 survivors out of 5 | Raw likelihood, including the binomial coefficient |
| Appendix: 2/5 versus 40/100 | Relative likelihood; each maximum is 1 |
| Coin likelihoods A and B | Relative likelihood; each maximum is 1 |

The relative-likelihood curves are divided by their own maxima, not normalised
to have area one. Likelihoods are not posterior probability densities for p.

### Move optional material out of the main sequence

Moved the following slides, with their content and speaker notes, to the Appendix
and marked each `visibility="uncounted"`:

- `What the MLE does not tell us`.
- `Forward problem: a positive PCR test`.
- `Inverse problem: infection after a positive test`.

The comparison of sample sizes is covered later by coins and the existing exercise.
PCR repeats the forward/inverse-conditioning lesson and introduces an additional
context; the main sequence now returns to seedlings sooner. Avoid presenting
Bayesian inference as the only way to quantify uncertainty beyond a point MLE.
The session-plan comment was updated to remove PCR from its core block.

### Slide 24: seedling posterior and its 95% interval

Title: `Seedlings again: posterior ∝ prior × likelihood`.

- Graph shows only the purple dashed Beta(1,1) prior and orange solid Beta(3,4)
  posterior. Likelihood is omitted from both the graph and legend because its
  shape is proportional to this posterior under the uniform prior.
- The equal-tailed 95% interval is shaded pale orange under the **posterior**;
  the region contains a `95%` label. Shading is behind the curves.
- Exact boundaries are 0.1181172 and 0.7772219, displayed as [0.12, 0.78]. The
  posterior mean is 3/7, displayed as 0.43.
- Right-hand labels use the corresponding prior/likelihood/posterior colours.
  The interval has an orange accent and pale background. CSS is scoped to this
  slide; shared helpers and themes were not changed.
- Current instructor-edited source also contains `Peak: 0.4 (= MLE)` and no longer
  displays the long probability-interpretation sentence below the interval.
  Preserve this current state when continuing work.
- The later Stan-draw summary was also changed to 95%, using quantiles 0.025 and
  0.975. This was a slide change, not a course-wide change to exercise intervals.

### Slide 25: coin likelihoods and common prior

The current instructor-edited title is `Prior vs. Data: MLE and Bayesian Inference`.
Preserve it rather than restoring the earlier proposed title
`Same MLE, different sample sizes`.

- Top: A = 3 heads / 5 tosses and B = 60 / 100, both with MLE = 0.6.
- Bottom left: Binomial likelihoods with peaks scaled to 1, common p axis 0–1,
  and y axis `Relative likelihood`.
- Bottom right: Beta(51,51) prior density on its own vertical scale. It explicitly
  states that the same prior is used for A and B and is strongly centred at 0.5.
- A is salmon (`#F8766D`) and solid; B is green (`#00BA38`) and dashed; the prior
  is purple (`#7570b3`) and dotdash. These styles match the following slide.
- Under `Likelihood A vs. B`, show aligned equations
  `L_A(p) ∝ p^3(1-p)^2` and `L_B(p) ∝ p^60(1-p)^40`, with coloured L labels.
  The earlier subtitle and in-panel `L_A: 3/5` / `L_B: 60/100` labels were removed
  at the instructor's request because the data counts already appear above.
- Coloured equations use base grid plotmath grobs in the ggplot subtitle area,
  combined with `patchwork::wrap_ggplot_grob()`. The blank subtitle in the code
  is intentional and replaced by these grobs. No new package was installed.

### Slide 26: posterior comparison

The data and distributions remain Beta(54,53) for A and Beta(111,91) for B, with
the common Beta(51,51) prior. Following the instructor's request, the explanation
is now three rows:

- **Post A (5 tosses):** The prior has a stronger influence, so the posterior
  stays close to the prior.
- **Post B (100 tosses):** The data have more influence, shifting the posterior
  toward the observed proportion (0.6).
- **Take-home message:** Same MLE (0.6), different posteriors.

A/B labels match their curve colours; the take-home message is bold. The plot
height is 3.7 inches and slide-scoped explanation text is 0.7em to fit the three
rows without wrapping. Notes retain the point that the strong prior still has
substantial influence with 100 tosses; do not describe B as unaffected by it.

## Files and validation

Edited `day1/slides.qmd` and regenerated `day1/slides.html`, with associated
generated figures. `day1/exercise.html` was already modified at session start and
was not edited by this session. No course fits, Stan code, shared R helpers,
exercise sources or other-day materials were changed.

Validation used local R 4.6.1, Quarto 1.10.19 and patchwork 1.3.2:

```bash
quarto render day1/slides.qmd
git diff --check -- day1/slides.qmd
```

- Repeated affected renders completed all 47 R chunks. Browser screenshots were
  inspected after layout changes, including the final slide 26 three-row layout.
  Plot text, equations, curve labels, shading and slide boundaries were checked.
- Numerical checks confirmed Normal log-likelihoods -5.006816 and -11.006816 at
  means 0 and 2; the curve peaks at mean 0.
- Binomial raw maxima are 0.3456 for 2/5 and 0.08121914 for 40/100, both at p=0.4.
- Coin relative likelihoods both peak at p=0.6 with height 1; B has the narrower
  half-maximum width (0.114 versus 0.482 on the plotting grid).
- `diff(pbeta(qbeta(c(0.025,0.975),3,4),3,4))` equals 0.95.
- Targeted source/HTML comparisons checked that narrow follow-up edits affected
  only the requested slide, or the explicitly allowed colour/linetype scales on
  the following slide. Concurrent instructor edits were preserved.

Initial sandbox rendering failed on the Quarto Sass cache. Normal-permission
renders succeeded. Renv still warns about missing/broken cache entries; no
dependency installation or repair was attempted. No model fitting, commit or push
was performed.

## Remaining work and best next action

1. Review/rehearse the updated Day 1 sequence and transitions using freshly loaded
   HTML. Existing browser tabs can retain old slides or cached figures; reload
   from origin when checking. Slide numbers after Appendix moves now run to 34
   in the main deck; the coin pair is 25–26.
2. The participant package, result sheets, instructor guide and classroom image
   were **not rebuilt during this session**. Do not assume the ZIP described as
   current in the earlier handoff includes these latest slide changes. Use the
   documented packaging workflow when preparing distribution.
3. Day 1 exercise/shared summary helpers still use 90% intervals in places. Decide
   separately whether to harmonise them with the revised slide examples; do not
   silently change all days or refit models to do so.

Do not redo the broad course restructure, bring the optional PCR/MLE comparison
back into core content, restore removed duplicate labels, or add independent Stan
implementation requirements. The latest requested slide edits are complete.

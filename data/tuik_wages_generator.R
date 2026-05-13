# tuik_wages_generator.R
#
# Synthetic teaching dataset for IKT2010 Week 7 (two-sample t-test).
# Calibrated to TÜİK Kazanç Yapısı Araştırması (Structure of Earnings Survey)
# and the ILO/TÜİK 2023 joint report finding that the gender wage gap in
# Turkey is ~15.6%.
#
# This is NOT raw microdata. It is a simulated dataset built to reproduce
# published aggregate statistics, for the purpose of teaching the two-sample
# independent t-test. The generator is shipped alongside the CSV so students
# and instructors can inspect how the numbers were produced.

set.seed(2026)

# ---- design parameters -------------------------------------------------------

n_f <- 600
n_m <- 600

# Target hourly wage in TRY, 2025 levels.
# Male:   mean ~180, SD ~45  (coefficient of variation 0.25)
# Female: mean ~152, SD ~38  (same CV; mean = 84.4% of male mean, matching
#                             the ILO/TÜİK 2023 report of ~15.6% gender gap)
mu_m <- 180
mu_f <- 152
cv   <- 0.25

# Log-normal gives the right-skewed shape that real wage data shows.
sdlog     <- sqrt(log(cv^2 + 1))
meanlog_m <- log(mu_m) - sdlog^2 / 2
meanlog_f <- log(mu_f) - sdlog^2 / 2

# ---- sample ------------------------------------------------------------------

wages_m <- round(rlnorm(n_m, meanlog = meanlog_m, sdlog = sdlog), 2)
wages_f <- round(rlnorm(n_f, meanlog = meanlog_f, sdlog = sdlog), 2)

df <- data.frame(
  id          = integer(n_f + n_m),
  gender      = c(rep("Female", n_f), rep("Male", n_m)),
  hourly_wage = c(wages_f, wages_m)
)

# Shuffle so rows aren't ordered by gender, then renumber ids.
df       <- df[sample(nrow(df)), ]
df$id    <- seq_len(nrow(df))
rownames(df) <- NULL

# ---- sanity checks -----------------------------------------------------------

cat("Group summaries:\n")
print(aggregate(hourly_wage ~ gender, data = df,
                FUN = function(x) c(n = length(x),
                                    mean = round(mean(x), 2),
                                    sd   = round(sd(x),   2))))

cat("\nFull-sample Welch t-test (expect p < 0.001):\n")
print(t.test(hourly_wage ~ gender, data = df))

cat("\nSeeded small subsample (n = 20 per group, seed = 42; expect p > 0.05):\n")
set.seed(42)
sub_idx <- c(sample(which(df$gender == "Female"), 20),
             sample(which(df$gender == "Male"),   20))
sub     <- df[sub_idx, ]
print(t.test(hourly_wage ~ gender, data = sub))

# ---- write -------------------------------------------------------------------

out <- "data/tuik_wages.csv"
write.csv(df, out, row.names = FALSE)
cat("\nWrote", nrow(df), "rows to", out, "\n")

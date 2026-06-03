# college_majors_generator.R
#
# Teaching dataset for IKT2010 (ANOVA + correlation exercise).
#
# Source: FiveThirtyEight "college-majors" (recent graduates), built from the
# US Census American Community Survey (ACS) PUMS, via
#   https://raw.githubusercontent.com/fivethirtyeight/data/master/college-majors/recent-grads.csv
#
# Returns to education: which fields of study pay best after graduation, and is
# a field's pay linked to how many women study it?
#
# Simplifications for teaching (earnings are NOT altered):
#  - collapsed the 16 detailed major categories into 5 broad fields so the
#    one-way ANOVA / Tukey stay readable
#  - kept a handful of columns, renamed to clean snake_case
#  - tidied the ALL-CAPS major names to Title Case

set.seed(2026)

url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/college-majors/recent-grads.csv"
raw <- read.csv(url, stringsAsFactors = FALSE)

field_map <- c(
  "Engineering"                         = "Engineering & Computing",
  "Computers & Mathematics"             = "Engineering & Computing",
  "Physical Sciences"                   = "Sciences & Health",
  "Biology & Life Science"              = "Sciences & Health",
  "Agriculture & Natural Resources"     = "Sciences & Health",
  "Health"                              = "Sciences & Health",
  "Business"                            = "Business & Law",
  "Law & Public Policy"                 = "Business & Law",
  "Social Science"                      = "Social Sciences",
  "Psychology & Social Work"            = "Social Sciences",
  "Communications & Journalism"         = "Social Sciences",
  "Interdisciplinary"                   = "Social Sciences",
  "Arts"                                = "Arts & Humanities",
  "Humanities & Liberal Arts"           = "Arts & Humanities",
  "Education"                           = "Arts & Humanities",
  "Industrial Arts & Consumer Services" = "Arts & Humanities"
)

df <- data.frame(
  major             = tools::toTitleCase(tolower(raw$Major)),
  field             = unname(field_map[raw$Major_category]),
  median_earnings   = raw$Median,
  share_women       = round(raw$ShareWomen, 3),
  unemployment_rate = round(raw$Unemployment_rate, 4),
  grads_total       = raw$Total,
  stringsAsFactors = FALSE
)
df <- df[!is.na(df$field) & !is.na(df$median_earnings) & !is.na(df$share_women), ]
rownames(df) <- NULL

# ---- sanity checks -----------------------------------------------------------
cat("rows:", nrow(df), "\n"); print(table(df$field))

cat("\nANOVA  median_earnings ~ field  (expect significant):\n")
fit <- aov(median_earnings ~ field, data = df)
print(summary(fit))
cat("\nTukey HSD:\n"); print(round(TukeyHSD(fit)$field, 1))

cat("\nStrong (negative) correlation  share_women ~ median_earnings:\n")
ct <- cor.test(df$share_women, df$median_earnings)
cat("  r =", round(ct$estimate, 3), " p =", signif(ct$p.value, 3), "\n")
cat("Weaker angle  unemployment_rate ~ median_earnings:\n")
cat("  r =", round(cor(df$unemployment_rate, df$median_earnings), 3), "\n")

write.csv(df, "data/college_majors.csv", row.names = FALSE)
cat("\nWrote", nrow(df), "rows to data/college_majors.csv\n")

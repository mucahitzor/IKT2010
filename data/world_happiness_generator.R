# world_happiness_generator.R
#
# Teaching dataset for IKT2010 (ANOVA + correlation exercise).
#
# Source: World Happiness Report 2015 (happiness scores from the Gallup World
# Poll / UN Sustainable Development Solutions Network), via the public mirror
#   https://raw.githubusercontent.com/dsrscientist/DSData/master/happiness_score_dataset.csv
#
# Simplifications for teaching (the numbers themselves are NOT altered):
#  - kept a handful of columns and renamed them to clean snake_case
#  - collapsed the 10 sub-regions into 4 macro-regions so the one-way ANOVA and
#    Tukey test stay readable (4 groups instead of 10)
#  - dropped Australia & New Zealand (only 2 countries, awkward to assign to a
#    macro-region)
#
# `gdp_per_capita` is the report's GDP-per-capita contribution score (higher =
# wealthier economy); the other factor columns are the report's estimated
# contributions to the happiness ladder.

set.seed(2026)

url <- "https://raw.githubusercontent.com/dsrscientist/DSData/master/happiness_score_dataset.csv"
raw <- read.csv(url, check.names = FALSE, stringsAsFactors = FALSE)

region_map <- c(
  "Western Europe"                  = "Europe",
  "Central and Eastern Europe"      = "Europe",
  "North America"                   = "Americas",
  "Latin America and Caribbean"     = "Americas",
  "Eastern Asia"                    = "Asia",
  "Southeastern Asia"               = "Asia",
  "Southern Asia"                   = "Asia",
  "Middle East and Northern Africa" = "Africa & Middle East",
  "Sub-Saharan Africa"              = "Africa & Middle East",
  "Australia and New Zealand"       = NA_character_   # dropped (only 2 countries)
)

df <- data.frame(
  country         = raw$Country,
  region          = unname(region_map[raw$Region]),
  happiness_score = round(raw$`Happiness Score`, 3),
  gdp_per_capita  = round(raw$`Economy (GDP per Capita)`, 4),
  social_support  = round(raw$Family, 4),
  life_expectancy = round(raw$`Health (Life Expectancy)`, 4),
  freedom         = round(raw$Freedom, 4),
  generosity      = round(raw$Generosity, 4),
  stringsAsFactors = FALSE
)
df <- df[!is.na(df$region), ]
rownames(df) <- NULL

# ---- sanity checks -----------------------------------------------------------
cat("rows:", nrow(df), "\n"); print(table(df$region))

cat("\nANOVA  happiness_score ~ region  (expect significant):\n")
fit <- aov(happiness_score ~ region, data = df)
print(summary(fit))
cat("\nTukey HSD:\n"); print(TukeyHSD(fit))

cat("\nStrong correlation  gdp_per_capita ~ happiness_score:\n")
print(cor.test(df$gdp_per_capita, df$happiness_score)$estimate)
cat("Weak / non-significant angle  generosity ~ happiness_score:\n")
gt <- cor.test(df$generosity, df$happiness_score)
cat("  r =", round(gt$estimate, 3), " p =", round(gt$p.value, 3), "\n")

write.csv(df, "data/world_happiness.csv", row.names = FALSE)
cat("\nWrote", nrow(df), "rows to data/world_happiness.csv\n")

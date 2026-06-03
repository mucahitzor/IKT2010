# box_office_generator.R
#
# Teaching dataset for IKT2010 (ANOVA + correlation exercise).
#
# Source: the "movies" dataset from vega-datasets (compiled from IMDB, Rotten
# Tomatoes and box-office figures), via
#   https://raw.githubusercontent.com/vega/vega-datasets/main/data/movies.json
#
# Film-industry economics: what makes a movie earn at the box office?
#
# Simplifications for teaching (figures are NOT altered):
#  - kept 5 big genres (Action, Adventure, Comedy, Drama, Horror)
#  - converted budget and worldwide gross to millions of US$
#  - dropped rows with missing/zero budget or gross, then took a seeded sample

set.seed(2026)

m <- jsonlite::fromJSON("https://raw.githubusercontent.com/vega/vega-datasets/main/data/movies.json")
names(m) <- make.names(names(m))

keep <- c("Action", "Adventure", "Comedy", "Drama", "Horror")
m <- m[!is.na(m$Major.Genre) & m$Major.Genre %in% keep &
       !is.na(m$Worldwide.Gross)    & m$Worldwide.Gross    > 0 &
       !is.na(m$Production.Budget)  & m$Production.Budget   > 0, ]

df <- data.frame(
  title                   = trimws(m$Title),
  genre                   = m$Major.Genre,
  budget_million          = round(m$Production.Budget / 1e6, 2),
  worldwide_gross_million = round(m$Worldwide.Gross   / 1e6, 2),
  imdb_rating             = m$IMDB.Rating,
  rotten_tomatoes         = m$Rotten.Tomatoes.Rating,
  running_time_min        = m$Running.Time.min,
  mpaa_rating             = m$MPAA.Rating,
  stringsAsFactors = FALSE
)
df <- df[sample(nrow(df), 200), ]
df <- df[order(-df$worldwide_gross_million), ]
rownames(df) <- NULL

# ---- sanity checks -----------------------------------------------------------
cat("rows:", nrow(df), "\n"); print(table(df$genre))

cat("\nANOVA  worldwide_gross_million ~ genre  (expect significant):\n")
fit <- aov(worldwide_gross_million ~ genre, data = df)
print(summary(fit))
cat("\nTukey HSD:\n"); print(round(TukeyHSD(fit)$genre, 1))

cat("\nStrong correlation  budget_million ~ worldwide_gross_million:\n")
cat("  r =", round(cor(df$budget_million, df$worldwide_gross_million), 3), "\n")
cat("Weak angle  imdb_rating ~ worldwide_gross_million (do better films earn more?):\n")
cat("  r =", round(cor(df$imdb_rating, df$worldwide_gross_million, use = "complete.obs"), 3), "\n")

write.csv(df, "data/box_office.csv", row.names = FALSE)
cat("\nWrote", nrow(df), "rows to data/box_office.csv\n")

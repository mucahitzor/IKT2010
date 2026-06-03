# fifa_players_generator.R
#
# Teaching dataset for IKT2010 (ANOVA + correlation exercise).
#
# Source: FIFA 19 complete player dataset (EA Sports / sofifa ratings), via
#   https://raw.githubusercontent.com/densaiko/data_science_learning/main/dataset/fifa_dataset.csv
#
# Think of a footballer's "market value" as the price of labour in a talent
# market: what determines how much a player is worth?
#
# Simplifications for teaching:
#  - parsed Value ("€110.5M") and Wage ("€565K") into plain numbers
#    (value in million €, wage in thousand €)
#  - collapsed the 27 detailed positions into 4 groups (Goalkeeper, Defender,
#    Midfielder, Forward)
#  - relabelled international reputation (FIFA's 1-5 star fame rating) into a
#    categorical group ("1-star", "2-star", ...)
#  - added `age_group`: age binned into 21 or under / 22-25 / 26-29 / 30+
#  - kept reasonably well-known players (overall rating >= 70) and took a
#    seeded random sample so the file is small enough to eyeball
#  - dropped players with no listed position or a €0 value

set.seed(2026)

url <- "https://raw.githubusercontent.com/densaiko/data_science_learning/main/dataset/fifa_dataset.csv"
raw <- read.csv(url, check.names = TRUE, stringsAsFactors = FALSE)

parse_eur <- function(x, k_is) {           # returns million (k_is="M") or thousand (k_is="K")
  x    <- gsub("€", "", x)            # strip euro sign
  unit <- toupper(gsub("[0-9.]", "", x))
  num  <- suppressWarnings(as.numeric(gsub("[A-Za-z]", "", x)))
  if (k_is == "M") ifelse(unit == "M", num, ifelse(unit == "K", num / 1000, num))
  else             ifelse(unit == "M", num * 1000, ifelse(unit == "K", num, num))
}

defender   <- c("CB","RB","LB","RCB","LCB","RWB","LWB")
midfielder <- c("CM","CDM","CAM","RM","LM","RCM","LCM","RDM","LDM","RAM","LAM")
forward    <- c("ST","CF","RF","LF","RW","LW","RS","LS")
pos_group <- ifelse(raw$Position == "GK", "Goalkeeper",
              ifelse(raw$Position %in% defender, "Defender",
               ifelse(raw$Position %in% midfielder, "Midfielder",
                ifelse(raw$Position %in% forward, "Forward", NA_character_))))

df <- data.frame(
  name                     = raw$Name,
  age                      = raw$Age,
  nationality              = raw$Nationality,
  club                     = raw$Club,
  position                 = pos_group,
  overall                  = raw$Overall,
  potential                = raw$Potential,
  value_million_eur        = round(parse_eur(raw$Value, "M"), 3),
  wage_thousand_eur        = round(parse_eur(raw$Wage,  "K"), 0),
  reputation               = paste0(raw$International.Reputation, "-star"),
  stringsAsFactors = FALSE
)

df <- df[!is.na(df$position) & !is.na(df$value_million_eur) &
         df$value_million_eur > 0 & df$overall >= 70, ]
df <- df[sample(nrow(df), 180), ]
df <- df[order(-df$overall), ]
rownames(df) <- NULL

df$age_group <- as.character(cut(df$age, breaks = c(0, 21, 25, 29, Inf),
                                 labels = c("21 or under", "22-25", "26-29", "30+")))
df <- df[, c("name", "age", "age_group", "nationality", "club", "position",
             "overall", "potential", "value_million_eur", "wage_thousand_eur", "reputation")]

# ---- sanity checks -----------------------------------------------------------
cat("rows:", nrow(df), "\n"); print(table(df$age_group))

cat("\nANOVA  value_million_eur ~ age_group  (primary; expect significant):\n")
fit <- aov(value_million_eur ~ age_group, data = df)
print(summary(fit))
cat("\nTukey HSD:\n"); print(round(TukeyHSD(fit)$age_group, 3))
cat("mean value (M EUR) by age group:\n"); print(round(tapply(df$value_million_eur, df$age_group, mean), 2))

cat("\nStrong correlation  overall ~ value_million_eur:\n")
cat("  r =", round(cor(df$overall, df$value_million_eur), 3), "\n")
cat("Surprise / non-significant angle  value ~ position:\n")
cat("  p =", round(summary(aov(value_million_eur ~ position, data = df))[[1]][["Pr(>F)"]][1], 3), "\n")

write.csv(df, "data/fifa_players.csv", row.names = FALSE)
cat("\nWrote", nrow(df), "rows to data/fifa_players.csv\n")

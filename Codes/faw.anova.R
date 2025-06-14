# This script is for analysis of variance of the data both in overall and weekly manners 
#Library required ----
library(tidyverse)
library(agricolae)

# Data preparation ---- 
faw.anova <- faw.weekly_clean %>%
  pivot_longer(cols = starts_with("Week"), 
               names_to = "Week", 
               values_to = "Count") %>%
  mutate(Week = str_replace(Week, "Week_", "Week "),
         Week = factor(Week, levels = paste("Week", 1:6)))

# Anova and HSD.test is here ----
# Function to get HSD results for each week
get.hsd.results <- function(week_data) {
  model <- aov(Count ~ Treatment, data = week_data)
  hsd <- HSD.test(model, "Treatment", group = TRUE)
  
  # Extracting the means and groups correctly for each week
  results <- data.frame(
    Treatment = rownames(hsd$means),
    mean = hsd$means$Count,  # or hsd$means[,1] if Count isn't the column name
    groups = hsd$groups[rownames(hsd$means), "groups"]
  )
  return(results)
}
# Applying the function here to get the anova
weekly.results <- faw.anova %>%
  group_by(Week) %>%
  group_modify(~ get.hsd.results(.x))
view(weekly.results)


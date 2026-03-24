
library(tidyverse)
library(janitor)


read.csv("https://raw.githubusercontent.com/mucahitzor/IKT2010/refs/heads/main/data/crime_data.csv") %>% 
  as_tibble() -> crime


crime


crime %>% 
  view()


crime %>% 
  summary()


crime %>% 
  tabyl(offender_status)
  
crime %>% 
  tabyl(offender_race)

crime %>% 
  tabyl(victim_race)


crime %>% 
  ggplot() + 
  aes(x = offender_age)

crime %>% 
  ggplot() + 
  aes(x = offender_age) +
  geom_histogram()


crime %>% 
  ggplot() + 
  aes(x = offender_age) +
  geom_histogram(binwidth = 5,fill = "beige", color = "black") +
  scale_x_continuous(n.breaks = 16) + 
  theme_bw()


crime %>% 
  ggplot() + 
  aes(x = offender_age) +
  geom_histogram(binwidth = 5,fill = "coral2", color = "black", boundary = 0) +
  scale_x_continuous(n.breaks = 16) + 
  theme_bw() -> offender_plot


crime %>% 
  ggplot() + 
  aes(x = victim_age) +
  geom_histogram(binwidth = 5,fill = "blue", color = "black", boundary = 0) +
  scale_x_continuous(n.breaks = 20) + 
  theme_bw() -> victim_plot



library(patchwork)


offender_plot + victim_plot

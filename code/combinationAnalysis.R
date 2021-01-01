#### load packages ####
library(tidyverse)
library(here)
library(knitr)
library(kableExtra)

#### load data ####

load(here('data', 'tidyDat.RData'))

#### analysis of combinations ####

# top 5
dat %>% 
  arrange(desc(percentValue)) %>% 
  mutate(` ` = 1:nrow(.)) %>% 
  filter(row_number() < 11) %>% 
  select(` `,
         Race,
         Class,
         Percent = percentValue) %>% 
  kable('html',
        digits = 0,
        caption = '5 Highest Combinations') %>% 
  kable_styling("striped", "bordered") %>% 
  footnote(general = "D&D Beyond Developer Update (Aug 29, 2018)", 
           general_title = "Source:", 
           footnote_as_chunk = T) %>% 
  as_image(file = here('plots', '5 Top Table.png'),
           density = 600)

# bottom 5
dat %>% 
  arrange(percentValue) %>% 
  mutate(` ` = nrow(.):1) %>% 
  filter(row_number() < 11) %>% 
  select(` `,
         Race,
         Class,
         Percent = percentValue) %>% 
  kable('html',
        digits = 0,
        caption = '5 Lowest Combinations') %>% 
  kable_styling("striped", "bordered") %>% 
  footnote(general = "D&D Beyond Developer Update (Aug 29, 2018)", 
           general_title = "Source:", 
           footnote_as_chunk = T) %>% 
  as_image(file = here('plots', '5 Bottom Table.png'),
           density = 600)


# most/least divergent races and classes

# Race

# top 5
dat %>% 
  group_by(Race) %>% 
  summarise(divergenceValue = sum(abs(log2Value))) %>% 
  arrange(desc(divergenceValue)) %>% 
  filter(row_number() < 6)

# bottom 5
dat %>% 
  group_by(Race) %>% 
  summarise(divergenceValue = sum(abs(log2Value))) %>% 
  arrange(divergenceValue) %>% 
  filter(row_number() < 6)

# Class

# top 5
dat %>% 
  group_by(Class) %>% 
  summarise(divergenceValue = sum(abs(log2Value))) %>% 
  arrange(desc(divergenceValue)) %>% 
  filter(row_number() < 6)

# bottom 5
dat %>% 
  group_by(Class) %>% 
  summarise(divergenceValue = sum(abs(log2Value))) %>% 
  arrange(divergenceValue) %>% 
  filter(row_number() < 6)

# distribution of values
dat %>% 
  ggplot(aes(x = log2Value)) +
  geom_histogram()


#### load packages ####
library(tidyverse)
library(here)
library(knitr)

#### load data ####

dat <- readRDS(here('data', 'tidyDat.rds'))

#### analysis of combinations ####

# top 10
dat %>% 
  arrange(desc(percentValue)) %>% 
  mutate(` ` = 1:nrow(.)) %>% 
  filter(row_number() < 11) %>% 
  select(` `,
         Race,
         Class,
         Percent = percentValue) %>% 
  kable('pipe',
        digits = 0,
        caption = '10 Highest Combinations') 

# bottom 10
dat %>% 
  arrange(percentValue) %>% 
  mutate(` ` = nrow(.):1) %>% 
  filter(row_number() < 11) %>% 
  select(` `,
         Race,
         Class,
         Percent = percentValue) %>% 
  kable('pipe',
        digits = 0,
        caption = '10 Lowest Combinations')


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


#### load packages ####
library(tidyverse)
library(here)

#### read in data ####
rawDat <- read_csv(here('data', 'Character Data 2018.csv'))

#### Wrangle data ####
dat <- rawDat %>%  pivot_longer(-Race, # convert to long form
                                names_to = 'Class',
                                values_to = 'obsValue') %>% 
  group_by(Race) %>% 
  mutate(raceTot = sum(obsValue)) %>% # calculate totals for race
  group_by(Class) %>% 
  mutate(classTot = sum(obsValue)) %>%  # calculate totals for classes
  ungroup() %>% 
  mutate(expValue = (raceTot * classTot) / sum(obsValue), # calculate expected freq
         diffValue = (obsValue - expValue)/expValue, # calc difference from expected
         log2Value = log2(diffValue + 1), # log2 transformation for colour scale
         percentValue = 100 * (obsValue / expValue)) # calc percent of expected

xCoords <- tibble(Class = colnames(rawDat)[-1], # X coordinates based on Class
                  x = 1:12)
yCoords <- tibble(Race = rawDat$Race, # Y coordinates based on Race
                  y = 20:1)

dat <- dat %>% left_join(xCoords) %>% # add X and Y coordinates
  left_join(yCoords)

#### Write tidy data file ####

save(dat,
     file = here('data', 'tidyDat.RData'))

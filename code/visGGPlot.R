#### load packages ####
library(tidyverse)
library(here)

#### load data ####

load(here('data', 'tidyDat.RData'))

##### create colour scale ####

# set colour scheme
# #23272A for Discord dark
# #121212
# #272727
bgColour <- 'white' # background, will work when saving as png, not when displayed
labelColour <- 'black' # axis and scale label text
valueColour <- labelColour # values text
hotColour <- 'red' # high end of scale
coldColour <- 'blue' # low end of scale
neutralColour <- bgColour # middle of scale

nn <- 200 # number of positions in each palette
scaleEnd <- max(abs(dat$log2Value))

# palettes for greater then expected (positive) and less than expected (negative)
posPalette <- colorRampPalette(c(neutralColour, hotColour), bias = 1)(n = nn)

negPalette <- colorRampPalette(c(neutralColour, coldColour), bias = 1)(n = nn)

# combine palettes and marks
myPalette <- c(negPalette[nn:2], posPalette)

##### ggplot ####
plot2 <- dat %>%
  mutate(Class = fct_inorder(Class),
         Race = fct_inorder(Race) %>% fct_rev()) %>% 
  ggplot(aes(x = Class,
             y = Race,
             fill = log2Value)) +
  geom_tile(show.legend = FALSE) + # can change to show key, don't feel it adds much
  geom_text(aes(label = percentValue %>% round())) +
  scale_x_discrete(position = 'top') +
  scale_fill_gradient2(palette = function(x) {
    tmpValue <- round(x * (length(myPalette) - 1)) + 1
    myPalette[tmpValue]
  }, 
  midpoint = 0,
  labels = c('¼x', '½x', '1x', '2x', '4x')) +
  labs(x = NULL, y = NULL) +
  theme_classic() +
  theme(axis.text = element_text(face = 'bold', size = rel(1)),
        axis.text.x = element_text(angle = 30, hjust = .2),
        legend.title = element_blank())
plot2

ggsave(filename = here('plots', 'DDB uniqueness scores.png'),
       plot = plot2,
       width = 8,
       height = 5)

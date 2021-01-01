##
##	DnD Beyond Character Data
##
##	examine uniqueness of race and class combination
##
##

#### load packages ####
library(tidyverse)
library(here)
library(lattice)
library(latticeExtra)
library(knitr)
library(kableExtra)

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

# palettes and marks for greater then expected (positive) and less than expected (negative)
posPalette <- colorRampPalette(c(neutralColour, hotColour), bias = 1)(n = nn)
posMarks <- seq(0, scaleEnd, length.out = nn)

negPalette <- colorRampPalette(c(neutralColour, coldColour), bias = 1)(n = nn)
negMarks <- seq(0, -scaleEnd, length.out = nn)

# combine palettes and marks
myPalette <- c(negPalette[nn:2], posPalette)
marks <- c(negMarks[nn:2], posMarks)

#### plot data ####

# text size adjustment variable
adjCex <- .8 # recommend .8 for viewing; 2 for printing image

# create level plot showing coloured boxes
plot1 <- levelplot(log2Value ~ x * y,
                   data = dat,
                   at = marks,
                   col.regions = myPalette,
                   # could include main title, x and y labels
                   # main = list(label = 'Percent of Expected Frequency', cex = 1.5 * adjCex, font = 1),
                   # xlab.top = list(label = 'Class',
                   #                 cex = 1.2 * adjCex,
                   #                 font = 2,
                   #                 col = labelColour)
                   ylab = list(label = NULL, # 'Race'
                               cex = 1.2 * adjCex,
                               font = 2,
                               col = labelColour),
                   xlab = NULL,
                   scales = list(x = list(at = 1:12,
                                          labels = xCoords$Class,
                                          font = 2,
                                          tck = 0,
                                          alternating = 2,
                                          rot = 30,
                                          col = labelColour),
                                 y = list(at = 1:20,
                                          labels = yCoords$Race[20:1],
                                          font = 2,
                                          tck = 0,
                                          col = labelColour),
                                 cex = 1 * adjCex),
                   colorkey = list(labels = list(cex = .75 * adjCex,
                                                 at = c(2, 1, 0, -1, -2),
                                                 labels = c('4x', '2x', '1x', '½x', '¼x'),
                                                 font = 2,
                                                 col = labelColour),
                                   tick.number = 5)
) +
  # add text labels showing percent of expected
  xyplot(y ~ x,
         data = dat,
         panel = function(y, x) {
           ltext(x = x,
                 y = y,
                 labels = round(dat$percentValue,
                                digits = 0),
                 cex = .75 * adjCex,
                 font = 2,
                 col = valueColour)
         }
  )
plot1


#### save plot ####

# uncomment to save as a png, recommend adjusting adjCex
png(filename = here('plots', 'DDB 2018 uniqueness scores.png'),
    width = 420*3.5,
    height = 420*2,
    pointsize = 12,
    bg = bgColour
)
print(plot1)
dev.off()

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


##### ggplot method ####
plot2 <- dat %>%
  mutate(Class = fct_inorder(Class),
         Race = fct_inorder(Race) %>% fct_rev()) %>% 
  ggplot(aes(x = Class,
             y = Race,
             fill = log2Value)) +
  geom_tile(show.legend = FALSE) +
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

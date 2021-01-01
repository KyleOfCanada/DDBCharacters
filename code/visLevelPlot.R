#### load packages ####
library(tidyverse)
library(here)
library(lattice)
library(latticeExtra)

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
adjCex <- 2 # recommend .8 for viewing; 2 for printing image

# create level plot showing coloured boxes

xCoords <- tibble(Class = unique(dat$Class), # X coordinates based on Class
                  x = 1:12)

yCoords <- tibble(Race = unique(dat$Race), # Y coordinates based on Race
                  y = 20:1)

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
# png(filename = here('plots', 'DDB uniqueness scores LevelPlot.png'),
#     width = 420*3.5,
#     height = 420*2,
#     pointsize = 12,
#     bg = bgColour
# )
# print(plot1)
# dev.off()

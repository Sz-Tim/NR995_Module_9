### NR995
### Module 9: Version Control
### Assignment Key



## Note: The real goal of this week is for you to become comfortable using git
## integrated with RStudio. The problems here are primarily to review concepts
## from previous weeks and to provide a context for you to practice using git
## and GitHub with an R-based project. 




###############
#--- Question 1 
# The mammal sleep dataset is included in the ggplot2 package and provides
# information about the sleeping habits of 83 species of mammals. Load the 
# dataset (hint: *library(ggplot2); data(msleep); ?msleep*). 

library(ggplot2)
data(msleep)
?msleep
str(msleep)  # columns are numeric or character -- not factors
summary(msleep) 


# How many categories of diet type (i.e., *vore*) are there? 

length(unique(msleep$vore))  
unique(msleep$vore)  # length(unique()) includes NA, incorrectly = 5
nlevels(factor(msleep$vore))  
levels(factor(msleep$vore))  # converting to factor identifies 4 non-NA levels


# Visually investigate whether daily sleep totals vary with diet type: Produce 
# a boxplot comparing the categories within the *vore* column, excluding records 
# that do not have data in the *vore* column. Remember to include informative 
# axis labels. Briefly describe in 1-2 sentences the major patterns in the plot.

## Method 1: Base R
msleep_noVoreNA <- subset(msleep, !is.na(msleep$vore))
boxplot(sleep_total ~ vore, data=msleep_noVoreNA, ylim=c(0,24), 
        xlab="Diet type (-vore)", ylab="Total daily sleep (hr)")

## Method 2: ggplot & dplyr
library(dplyr); library(ggplot2)
msleep_noVoreNA <- filter(msleep, !is.na(vore)) # dplyr -- identical to above
ggplot(msleep_noVoreNA, aes(x=vore, y=sleep_total)) + ylim(0,24) + 
  geom_boxplot() + labs(x="Diet type (-vore)", y="Total daily sleep (hr)")

## Note: subsetting/filtering/etc can be nested within each plot function 
## instead if the altered dataframe is only used once. If it is used repeatedly,
## storing it as a separate object reduces repetition and simplifies de-bugging.




###############
#--- Question 2
# Using the mammal sleep dataset, use the *plot()* function to show the 
# relationship between the natural log of body size and the length of the sleep
# cycle, labelling axes appropriately. 

library(ggplot2); data(msleep)  # if not already run
plot(sleep_cycle ~ log(bodywt), data=msleep, 
     xlab="Log body weight (ln(kg))", ylab="Length of sleep cycle (hr)")

# Using *ggplot*, produce this same plot, but with a separate panel for each 
# conservation status, excluding species that do not have data for all 
# variables, and including a trend line with *+ stat_smooth(method="lm", se=F)*.
# Do the species within each conservation status appear to show the same 
# relationship between weight and sleep cycle length? Which categories appear 
# most data-deficient?

## remove rows that with NA's for bodwt, sleep_cycle, or conservation
ggplot(filter(msleep, 
              !is.na(bodywt) & !is.na(sleep_cycle) & !is.na(conservation)), 
       aes(x=log(bodywt), y=sleep_cycle)) + 
  geom_point() + stat_smooth(method="lm", se=F) + 
  facet_wrap(~conservation) + 
  labs(x="Log body weight (ln(kg))", y="Length of sleep cycle (hr)")




###############
#--- Question 3 
# How does the ratio of brain weight to body weight (i.e., *brainwt*/*bodywt*)
# vary by diet type? Write a function called *brain_body_ratio()* that returns 
# a dataframe with a row for each diet type category (i.e., *vore*), and three
# columns named *vore*, *brain_body_mean*, and *brain_body_se*, where 
# *brain_body_mean* contains the mean brain-to-body weight ratio within a 
# *vore* category, and *brain_body_sd* contains the standard deviation for the
# brain-to-body weight ratio within a *vore* category. 

library(ggplot2); data(msleep)  # if not already run

## step 1: create standard error function
se <- function(x) {
  sem <- sd(x, na.rm=TRUE)/sqrt(length(na.omit(x)))
  return(sem)
}

## step 2: create brain_body_ratio function
# Method 1: Base R
brain_body_ratio <- function(x.df) {
  summary.df <- data.frame(vore=unique(x.df$vore),
                           brain_body_mean=rep(NA,length(unique(x.df$vore))),
                           brain_body_se=rep(NA,length(unique(x.df$vore))))
  
  x.df$ratio <- x.df$brainwt/x.df$bodywt
  summary.df$brain_body_mean <- tapply(x.df$ratio, x.df$vore, mean, na.rm=TRUE)
  summary.df$brain_body_se <- tapply(x.df$ratio, x.df$vore, se)
  
  return(summary.df)
}
brain_body_ratio(subset(msleep, !is.na(msleep$vore)))

## step 2: create brain_body_ratio function
# Method 2: dplyr
brain_body_ratio <- function(x.df) {
  # In dplyr, the pipe operator %>% allows you to string together outputs and
  # inputs rather than nesting functions within one another. For example, 
  # instead of removing NA's and summarizing a dataset with:
  #     summary(subset(x.df, x.df$var1 > 10))
  # the pipe operator allows you to code the same as:
  #     subset(x.df, x.df$var1 > 10) %>% summary()
  # or, using dplyr::filter(), even:
  #     x.df %>% filter(var1 > 10) %>% summary()
  # It is a bit more advanced, but increases the readability of your code if 
  # you're applying multiple sequential operations to a dataset. By default, 
  # the output from the (left-hand) 'piped from' function is the *first* input
  # for the (right-hand) 'piped to' function. Read more with ?`%>%`
  require(dplyr)
  x.df <- x.df %>%
    mutate(ratio=brainwt/bodywt) %>% 
    group_by(vore) %>% 
    summarise(brain_body_mean=mean(ratio, na.rm=TRUE), 
              brain_body_se=se(ratio))
  return(x.df)
}
brain_body_ratio(filter(msleep, !is.na(vore)))


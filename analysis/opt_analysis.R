library(medicaldata)
library(ggplot2)
data(opt, package = "medicaldata")
ggplot(data = opt, aes(x = Birthweight, fill = Group)) +
    geom_histogram(position = "dodge") # looks normal-ish

## data cleaning##
opt_red <- opt[, c(1:22, 72)]
# Change NAs to "None" for diabetic
# since in opt the non-diabetic people are coded as NA (and therefore excluded from the model)
diab <- as.character(opt_red$BL.Diab.Type)
diab[is.na(diab)] <- "None"
opt_red$BL.Diab.Type <- as.factor(diab)
# similar problem with smokers and how many cigarettes per day

# If people are non-smokers and have missing for number of cigarettes per day
# change their number of cigarettes to zero
sm <- opt_red$Use.Tob
cigs <- opt_red$BL.Cig.Day
cigs[(is.na(cigs) & (sm == "No "))] <- 0
opt_red$BL.Cig.Day <- cigs

# Same for alcohol and drinks per day

alc <- opt_red$Use.Alc
dr <- opt_red$BL.Drks.Day
dr[(is.na(dr) & (alc == "No "))] <- 0
opt_red$BL.Drks.Day <- dr

# If a participant hasn't had a previous pregnancy, her N.prev.preg should be zero (not NA)

pp <- opt_red$Prev.preg
npp <- opt_red$N.prev.preg
npp[pp == "No "] <- 0
opt_red$N.prev.preg <- npp


## t-test on birthweight##
# Check SDs are fairly close before proceeding
sd(opt_red$Birthweight[opt_red$Group == "T"], na.rm = T)
sd(opt_red$Birthweight[opt_red$Group == "C"], na.rm = T)

t.test(
    x = opt_red$Birthweight[opt_red$Group == "T"],
    y = opt_red$Birthweight[opt_red$Group == "C"],
    alternative = "two.sided",
    var.equal = T, # this makes the method use pooled variances, as we did in lectures
    conf.level = 0.95 # note that this is 1-alpha
)
# not significant

## ancova model##
lm_full <- lm(Birthweight ~ ., data = opt_red[, -1]) # don't include the ID column!
summary(lm_full)
# very low rsquare - bad model

# check residuals
opt_diag <- na.omit(opt_red) # lm only fits where all variables are present
opt_diag$resid <- resid(lm_full)
opt_diag$fitted <- fitted(lm_full)
ggplot(data = opt_diag, aes(x = resid, fill = Group)) +
    geom_histogram(position = "dodge")
ggplot(data = opt_diag, aes(x = fitted, y = resid, col = Group)) +
    geom_point()

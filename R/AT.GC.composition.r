


###########################
###AT and CG composition###
###########################

setwd("/media/tandrean/Elements/PhD/ChIP.Update.Experiments/Prediction.Noisy.mESCs/CG.contents")
noisy <- read.table("Noisy.mm10.mESC.bed.for.Nuc.CG.and.AT",header = F)
control <- read.table("Noisy.mm10.control.mESC.bed.for.Nuc.CG.and.AT",header = F)


noisy$AT <- noisy$V4
control$AT <- control$V4
t.test(noisy$AT,control$AT)

noisy$condition <- 'noisy'
control$condition <- 'control'
head(noisy)
head(control)
definitive.AT <- rbind(noisy[,13:14], control[,13:14])
ggplot(definitive.AT, aes(AT, fill = condition)) + geom_density(alpha = 0.4) + xlim(0,1)+
  ggtitle("AT Percentage in the Noisy regions and Control regions in mESC \n p-value = 8.45e-08 ") +
  theme(plot.title = element_text(hjust = 0.5))

noisy$CG <- noisy$V5
control$CG <- control$V5
str(t.test(noisy$CG,control$CG))

noisy$condition <- 'noisy'
control$condition <- 'control'
head(noisy)
definitive.CG <- rbind(noisy[,15:14], control[,15:14])
ggplot(definitive.CG, aes(CG, fill = condition)) + geom_density(alpha = 0.4) + xlim(0,1) +
  ggtitle("CG Percentage in the Noisy regions and random control regions in mESC \n p-value = 2.51e-20 ") +
  theme(plot.title = element_text(hjust = 0.5))



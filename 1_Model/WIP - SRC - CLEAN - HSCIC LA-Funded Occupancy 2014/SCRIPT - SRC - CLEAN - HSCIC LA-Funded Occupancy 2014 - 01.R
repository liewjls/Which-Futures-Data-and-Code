library(plyr)
library(reshape2)

setwd("~/DataDive Workings/HSCIC Source")
hscic <- read.csv("S2_Final.csv", check.names = FALSE)
head(hscic)
hscic$Total <- NULL

m <- melt(hscic, id = c("AgeCategory", "ServiceType"), variable = "HSCIC_Region", value.name = "N_Council_Funded_Occupancy")
head(m)

setwd("~/DataDive Workings/1. Raw Data")
LA.map <- read.csv("HSCIC_ONS_LA_Mapping.csv")
head(LA.map)

hscic.mapped <-merge(m, LA.map, by = "HSCIC_Region", all.x = TRUE)
head(hscic.mapped)
hscic.mapped[is.na(hscic.mapped$ONS.LA.Code),]

hscic.mapped$HSCIC_Region <- NULL

# Need to combine City of London and Westminster & Cornwall and Isles of Scilly
aggs <- subset(hscic.mapped, ONS.LA.Code == "E09000033" | ONS.LA.Code == "E09000001")
aggs
hscic.mapped <- hscic.mapped[hscic.mapped$ONS.LA.Code != "E09000033" & hscic.mapped$ONS.LA.Code != "E09000001", ]

head(hscic.mapped)
d <- ddply(aggs, .(AgeCategory, ServiceType), summarise, ONS.LA.Code = "E09000033/E09000001", ONS.LA.Name = "Westminster,City of London", N_Council_Funded_Occupancy = sum(N_Council_Funded_Occupancy))
hscic.mapped <- as.data.frame(rbind(hscic.mapped, d))

aggs <- subset(hscic.mapped, ONS.LA.Code == "E06000052" | ONS.LA.Code == "E06000053")
hscic.mapped <- hscic.mapped[hscic.mapped$ONS.LA.Code != "E06000052" & hscic.mapped$ONS.LA.Code != "E06000053", ]
d <- ddply(aggs, .(AgeCategory, ServiceType), summarise, ONS.LA.Code = "E06000052/E06000053", ONS.LA.Name = "Cornwall,Isles of Scilly", N_Council_Funded_Occupancy = sum(N_Council_Funded_Occupancy))
hscic.mapped <- as.data.frame(rbind(hscic.mapped, d))
unique(hscic.mapped$ONS.LA.Name)

head(hscic.mapped)

write.csv(hscic.mapped, "HSCIC_2014_Occupancy_Mapped.csv")
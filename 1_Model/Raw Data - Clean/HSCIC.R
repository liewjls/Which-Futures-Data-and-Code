library(plyr)
library(reshape2)

setwd("~/DataKind/2015 DataDive Bristol/1. Raw Data")
hscic <- read.csv("HSCIC_2014_Pop.csv", check.names = FALSE)

m <- melt(hscic, id = c("ItemBaseID", "TextName", "Primary_Category", "Age_Category", "CompSerTypeCode", "TypeStayCode"), variable = "HSCIC_Region", value.name = "N_Council_Funded_Occupancy")
head(m)

LA.map <- read.csv("HSCIC_ONS_LA_Mapping.csv")

hscic.mapped <-merge(m, LA.map, by = "HSCIC_Region", all.x = TRUE)
head(hscic.mapped)
hscic.mapped[is.na(hscic.mapped$ONS.LA.Code),]

hscic.mapped$HSCIC_Region <- NULL

# Need to combine City of London and Westminster & Cornwall and Isles of Scilly
aggs <- subset(hscic.mapped, ONS.LA.Code == "E09000033" | ONS.LA.Code == "E09000001")
aggs
hscic.mapped <- hscic.mapped[hscic.mapped$ONS.LA.Code != "E09000033" & hscic.mapped$ONS.LA.Code != "E09000001", ]

d <- ddply(aggs, .(TextName, Primary_Category, Age_Category, CompSerTypeCode, TypeStayCode), summarise, ONS.LA.Code = "E09000033/E09000001", ONS.LA.Name = "Westminster,City of London", ItemBaseID = "Combined", N_Council_Funded_Occupancy = sum(N_Council_Funded_Occupancy))
hscic.mapped <- as.data.frame(rbind(hscic.mapped, d))

aggs <- subset(hscic.mapped, ONS.LA.Code == "E06000052" | ONS.LA.Code == "E06000053")
hscic.mapped <- hscic.mapped[hscic.mapped$ONS.LA.Code != "E06000052" & hscic.mapped$ONS.LA.Code != "E06000053", ]
d <- ddply(aggs, .(TextName, Primary_Category, Age_Category, CompSerTypeCode, TypeStayCode), summarise, ONS.LA.Code = "E06000052/E06000053", ONS.LA.Name = "Cornwall,Isles of Scilly", ItemBaseID = "Combined", N_Council_Funded_Occupancy = sum(N_Council_Funded_Occupancy))
hscic.mapped <- as.data.frame(rbind(hscic.mapped, d))
unique(hscic.mapped$ONS.LA.Name)

write.csv(hscic.mapped, "HSCIC_2014_Occupancy_Mapped.csv")

hscic.by.age <- ddply(hscic.mapped, .(Age_Category, ONS.LA.Code, ONS.LA.Name), summarise, N_Council_Funded_Occupancy = sum(N_Council_Funded_Occupancy))
head(hscic.by.age)
write.csv(hscic.by.age, "HSCIC_2014_Occupancy_Aggregate_By_Age_And_LA.csv")

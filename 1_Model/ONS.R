library(plyr)
library(reshape2)

# Clean ONS Population data and aggregate up to 65+ and 85+ elderly populations

setwd("~/DataKind/2015 DataDive Bristol/1. Raw Data")
pop <- read.csv("ONS_Population_Forecast.csv", check.names = FALSE)
head(pop)

m <- melt(pop, id = c("ONS.LA.Code", "ONS.LA.Name", "Age.Group"), variable = "Year", value.name = "Population")
head(m)

age65above <- aggregate(Population ~ ONS.LA.Code + ONS.LA.Name + Year, FUN = sum, subset = Age.Group != "All ages", data = m)
names(age65above)[4] <- "Pop.Age.65pl"

age85above <- aggregate(Population ~ ONS.LA.Code + ONS.LA.Name + Year, FUN = sum, subset = c(Age.Group == "85-89" | Age.Group == "90+"), data = m)
names(age85above)[4] <- "Pop.Age.85pl"
head(age85above)
pop65.85 <- merge(age65above, age85above, by = c("ONS.LA.Code", "ONS.LA.Name", "Year"))
head(pop65.85)

# Need to combine City of London and Westminster & Cornwall and Isles of Scilly
aggs <- subset(pop65.85, ONS.LA.Code == "E09000033" | ONS.LA.Code == "E09000001")
pop65.85 <- pop65.85[pop65.85$ONS.LA.Code != "E09000033" & pop65.85$ONS.LA.Code != "E09000001", ]

d <- ddply(aggs, .(Year), summarise, ONS.LA.Code = "E09000033/E09000001", ONS.LA.Name = "Westminster,City of London", Pop.Age.65pl = sum(Pop.Age.65pl), Pop.Age.85pl = sum(Pop.Age.85pl))
pop65.85 <- as.data.frame(rbind(pop65.85, d))

aggs <- subset(pop65.85, ONS.LA.Code == "E06000052" | ONS.LA.Code == "E06000053")
pop65.85 <- pop65.85[pop65.85$ONS.LA.Code != "E06000052" & pop65.85$ONS.LA.Code != "E06000053", ]
d <- ddply(aggs, .(Year), summarise, ONS.LA.Code = "E06000052/E06000053", ONS.LA.Name = "Cornwall,Isles of Scilly", Pop.Age.65pl = sum(Pop.Age.65pl), Pop.Age.85pl = sum(Pop.Age.85pl))
pop65.85 <- as.data.frame(rbind(pop65.85, d))
unique(pop65.85$ONS.LA.Name)

# Resident Care Occupants
res <- read.csv("ONS_ResCareOccupants2011.csv")
head(res)

res$Year <- "2011"
head(pop65.85)

pop65.85$Pop.Age.65pl <- pop65.85$Pop.Age.65pl*1000
pop65.85$Pop.Age.85pl <- pop65.85$Pop.Age.85pl*1000

df <- merge(pop65.85, res, by = c("ONS.LA.Code", "ONS.LA.Name", "Year"), all.x = TRUE) #from 9836 to 9490 because of exclusion of Wales
head(df) 

write.csv(df, "ONS_Cleaned.csv", row.names = FALSE)

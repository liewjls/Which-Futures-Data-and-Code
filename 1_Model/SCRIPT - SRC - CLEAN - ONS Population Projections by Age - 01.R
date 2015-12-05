library(plyr)
library(reshape2)

# Clean ONS Population data and aggregate up to 65+ and 85+ elderly populations

setwd("~/DataDive Workings/ONS Source")
pop <- read.csv("ONS_Population_Forecast.csv", check.names = FALSE)
head(pop)

m <- melt(pop, id = c("ONS.LA.Code", "ONS.LA.Name", "Age.Group"), variable = "Year", value.name = "Population")
head(m)

age65.74 <- aggregate(Population ~ ONS.LA.Code + ONS.LA.Name + Year, FUN = sum, subset = c(Age.Group == "65-69" | Age.Group == "70-74"), data = m)
names(age65.74)[4] <- "Pop.Age.65.74"


age75.84 <- aggregate(Population ~ ONS.LA.Code + ONS.LA.Name + Year, FUN = sum, subset = c(Age.Group == "75-79" | Age.Group == "80-84"), data = m)
names(age75.84)[4] <- "Pop.Age.75.84"

age85above <- aggregate(Population ~ ONS.LA.Code + ONS.LA.Name + Year, FUN = sum, subset = c(Age.Group == "85-89" | Age.Group == "90+"), data = m)
names(age85above)[4] <- "Pop.Age.85pl"
head(age85above)
pop65.85 <- merge(age65.74, age75.84, by = c("ONS.LA.Code", "ONS.LA.Name", "Year"))
pop65.85 <- merge(pop65.85, age85above, by = c("ONS.LA.Code", "ONS.LA.Name", "Year"))

head(pop65.85)

# Need to combine City of London and Westminster & Cornwall and Isles of Scilly
aggs <- subset(pop65.85, ONS.LA.Code == "E09000033" | ONS.LA.Code == "E09000001")
pop65.85 <- pop65.85[pop65.85$ONS.LA.Code != "E09000033" & pop65.85$ONS.LA.Code != "E09000001", ]

d <- ddply(aggs, .(Year), summarise, ONS.LA.Code = "E09000033/E09000001", ONS.LA.Name = "Westminster,City of London", Pop.Age.65.74 = sum(Pop.Age.65.74), Pop.Age.75.84 = sum(Pop.Age.75.84), Pop.Age.85pl = sum(Pop.Age.85pl))
pop65.85 <- as.data.frame(rbind(pop65.85, d))

aggs <- subset(pop65.85, ONS.LA.Code == "E06000052" | ONS.LA.Code == "E06000053")
pop65.85 <- pop65.85[pop65.85$ONS.LA.Code != "E06000052" & pop65.85$ONS.LA.Code != "E06000053", ]
d <- ddply(aggs, .(Year), summarise, ONS.LA.Code = "E06000052/E06000053", ONS.LA.Name = "Cornwall,Isles of Scilly", Pop.Age.65.74 = sum(Pop.Age.65.74), Pop.Age.75.84 = sum(Pop.Age.75.84), Pop.Age.85pl = sum(Pop.Age.85pl))
pop65.85 <- as.data.frame(rbind(pop65.85, d))
unique(pop65.85$ONS.LA.Name)

head(pop65.85)

setwd("~/DataKind/1_Model")
write.csv(df, "SRC - CLEAN - ONS Population Projections by Age.csv", row.names = FALSE)

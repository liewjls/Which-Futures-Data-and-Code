#If package NOT installed, install package
list.of.packages <- c("ggplot2","shapefiles","maptools","ggmap","scales","dplyr","shiny","shinythemes")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#Load packages
library(ggplot2)  
library(shapefiles)
library(maptools)
library(foreig)
setwd("C:/Users/red74/Dropbox/countries_2014_boundaries_full_extent")

#Load data, transform to Data.frame, then load in shape file data
x<- read.dbf("CTYUA_DEC_2014_EW_BGC.dbf")

x<- as.data.frame(x)
y<- x$dbf.CTYUA14NM[1:152]

ukR<- readShapeSpatial("County_and_unitary_authorities_(E+W)_2014_Boundaries_(Generalised_Clipped)/CTYUA_DEC_2014_EW_BGC.shp")

ukR.2<- ukR[1:152,]

#Convert shapefile to data.frame then plot & view
uk1<- fortify(ukR)
uk1.1<- fortify(ukR.2)

ggplot(uk1.1) +
  aes(long, lat, group = group) +
  geom_polygon() + 
  geom_path(color = "white", size = 0.25)

View(uk1)
View(ukR)

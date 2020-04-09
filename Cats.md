---
title: "CR Test 1"
output: 
  html_document: 
    keep_md: yes
---





# Hydrological time series


```r
isotopes <- read.csv("https://raw.githubusercontent.com/wdnguyen/CR/master/knappett_isotopes.csv")
rain <- read.csv("https://raw.githubusercontent.com/wdnguyen/CR/master/DownstreamMiller.csv")

isotopes$Date_Time <- strptime(isotopes$Date_Time, format = "%m/%d/%y %H:%M")
rain$Date <- strptime(rain$Date, format ="%m/%d/%y %H:%M")
```

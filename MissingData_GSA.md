---
title: "MissingData"
author: "William Nguyen"
date: "10/4/2020"
output: 
  html_document:
    keep_md: yes
---



## Imputing missing water quality data in the Howler Monkey Watershed

There's a couple ad-hoc ways of dealing with miss data, such as listwise deletion and mean imputation. Listwise deletion only really works when you have a few missing values and mean imputation brings too much bias to variances and covariances. In this example, I'll be using Amelia to perform multiple imputation, which should give me some probable predictions for my missing values.

In the future, I may want to implement some more robust means of imputation, such as CART, random forest, and artificial neural networks, but I'll save that for the manuscript. 




```r
df <- read.csv("https://raw.githubusercontent.com/wdnguyen/CR/master/CostaRica_Chemistry_Q_20201002.csv", stringsAsFactors = FALSE)
df$SamplingDate <- as.POSIXct(df$SamplingDate, format ="%m/%d/%y %H:%M")

### For now, let's set BDL as 0.1, globally (across all data)
df <- dplyr::mutate_if(tibble::as_tibble(df), # changed as.tibble to as_tibble
                       is.character,
                       stringr::str_replace_all, pattern = "BDL", replacement = "0.1")

### Convert character vectors into numeric (hopefully blanks become NA)
df[,c(12,13,15,17,19,24,28)] <- sapply(df[,c(12,13,15,17,19,24,28)], as.numeric) # NH3_f, H2S_f, Fetot, Mn_f, As_f, F, Li

### And for good measure, I will replace all negative concentrations with NA. https://cran.r-project.org/web/packages/naniar/vignettes/replace-with-na.html
df <- df %>%
  replace_with_na_at(.vars = c("Mo","U","Al","Si","Ca","Cr","Fe","Ti","B","Ba","As"),
                     condition = ~.x < 0) # I could have just used replace_with_na_all, but O18 and D have natural negative values

### Subsetting data by site / end-member
DS <- subset(df, Site == "Downstream")
US <- subset(df, Site == "Upstream")
SOIL <- subset(df, Site == "Soil")
RAIN <- subset(df, Site == "Rain")
SPRING <- subset(df, Site == "Spring")

### Just 2018 Data
DS2019 <- DS[format(DS$SamplingDate, '%Y') != "2019", ]
US2019 <- US[format(US$SamplingDate, '%Y') != "2019", ]
SOIL2019 <- SOIL[format(SOIL$SamplingDate, '%Y') != "2019", ]
RAIN2019 <- RAIN[format(RAIN$SamplingDate, '%Y') != "2019", ]
SPRING2019 <- SPRING[format(SPRING$SamplingDate, '%Y') != "2019", ]
```

OK cool, let's do a summary of df:


```r
summary(df)
```

```
##     ï..ID            SamplingDate                 Chemetrics_Acidified_Date
##  Length:91          Min.   :2018-07-01 15:06:00   Length:91                
##  Class :character   1st Qu.:2018-07-07 10:20:00   Class :character         
##  Mode  :character   Median :2018-07-08 07:56:00   Mode  :character         
##                     Mean   :2018-11-10 14:43:05                            
##                     3rd Qu.:2019-06-27 10:15:00                            
##                     Max.   :2019-07-12 16:10:00                            
##                                                                            
##      Site              Source               Temp            SPCOND      
##  Length:91          Length:91          Min.   : 21.80   Min.   :  5.00  
##  Class :character   Class :character   1st Qu.: 21.90   1st Qu.: 86.88  
##  Mode  :character   Mode  :character   Median : 22.10   Median :110.95  
##                                        Mean   : 24.97   Mean   : 98.75  
##                                        3rd Qu.: 23.10   3rd Qu.:116.20  
##                                        Max.   :222.90   Max.   :217.90  
##                                        NA's   :8        NA's   :7       
##        pH             ORP          AlkalinityS     AlkalinityW    
##  Min.   :3.300   Min.   :-115.0   Min.   :14.00   Min.   :  0.00  
##  1st Qu.:6.585   1st Qu.: 191.0   1st Qu.:19.00   1st Qu.: 41.40  
##  Median :7.100   Median : 288.4   Median :39.00   Median : 46.60  
##  Mean   :6.866   Mean   : 259.0   Mean   :34.69   Mean   : 42.98  
##  3rd Qu.:7.500   3rd Qu.: 359.0   3rd Qu.:47.00   3rd Qu.: 50.00  
##  Max.   :8.890   Max.   : 412.7   Max.   :53.00   Max.   :108.00  
##  NA's   :8       NA's   :10       NA's   :80      NA's   :16      
##      NH3_f            H2S_f            NO3_f            Fetot       
##  Min.   :0.0000   Min.   :0.0000   Min.   :0.0000   Min.   :0.1000  
##  1st Qu.:0.0700   1st Qu.:0.0200   1st Qu.:0.0600   1st Qu.:0.1000  
##  Median :0.1265   Median :0.0430   Median :0.2200   Median :0.1000  
##  Mean   :0.2972   Mean   :0.1019   Mean   :0.4107   Mean   :0.2364  
##  3rd Qu.:0.3480   3rd Qu.:0.1000   3rd Qu.:0.4150   3rd Qu.:0.1000  
##  Max.   :2.4800   Max.   :0.8500   Max.   :2.3580   Max.   :3.0000  
##  NA's   :13       NA's   :16       NA's   :12       NA's   :47      
##        O2              Mn_f         SO4_f            As_f      TotalNField    
##  Min.   : 4.779   Min.   :0.1   Min.   :0.207   Min.   :0.1   Min.   :0.0000  
##  1st Qu.: 7.402   1st Qu.:0.1   1st Qu.:0.555   1st Qu.:0.1   1st Qu.:0.0850  
##  Median : 7.896   Median :0.1   Median :1.042   Median :0.1   Median :0.1950  
##  Mean   : 7.949   Mean   :0.1   Mean   :1.193   Mean   :0.1   Mean   :0.5744  
##  3rd Qu.: 8.538   3rd Qu.:0.1   3rd Qu.:1.680   3rd Qu.:0.1   3rd Qu.:0.8100  
##  Max.   :15.990   Max.   :0.1   Max.   :2.480   Max.   :0.1   Max.   :3.0900  
##  NA's   :49       NA's   :83    NA's   :87      NA's   :88    NA's   :45      
##       DOC              TDN               Cl               Fl         
##  Min.   : 0.150   Min.   :0.0000   Min.   :0.1016   Min.   :0.00000  
##  1st Qu.: 0.610   1st Qu.:0.0900   1st Qu.:1.9795   1st Qu.:0.00940  
##  Median : 0.795   Median :0.1000   Median :2.0680   Median :0.02630  
##  Mean   : 1.778   Mean   :0.1264   Mean   :2.2038   Mean   :0.04489  
##  3rd Qu.: 1.715   3rd Qu.:0.1200   3rd Qu.:2.3881   3rd Qu.:0.10000  
##  Max.   :13.690   Max.   :1.3100   Max.   :4.5777   Max.   :0.10000  
##  NA's   :35       NA's   :35       NA's   :9        NA's   :10       
##       NO2              NO3              SO4               Li          
##  Min.   :0.1532   Min.   :0.0261   Min.   :0.0619   Min.   :0.000100  
##  1st Qu.:1.5727   1st Qu.:0.2003   1st Qu.:0.8308   1st Qu.:0.000900  
##  Median :1.9399   Median :0.2827   Median :0.9094   Median :0.001200  
##  Mean   :1.7672   Mean   :0.2720   Mean   :0.9741   Mean   :0.004455  
##  3rd Qu.:2.0978   3rd Qu.:0.3376   3rd Qu.:1.1056   3rd Qu.:0.002100  
##  Max.   :2.9490   Max.   :0.6564   Max.   :2.5605   Max.   :0.100000  
##  NA's   :9        NA's   :10       NA's   :9        NA's   :22        
##      Na_IC              K_IC           Mg_IC            Ca_IC        
##  Min.   : 0.0981   Min.   :0.109   Min.   :0.0105   Min.   : 0.0702  
##  1st Qu.: 6.6800   1st Qu.:2.397   1st Qu.:1.9118   1st Qu.: 9.5338  
##  Median : 8.7721   Median :2.878   Median :2.0198   Median :10.1884  
##  Mean   : 8.0922   Mean   :2.945   Mean   :2.2494   Mean   : 9.5753  
##  3rd Qu.: 9.4597   3rd Qu.:3.266   3rd Qu.:2.1492   3rd Qu.:10.7749  
##  Max.   :21.3885   Max.   :6.059   Max.   :6.2953   Max.   :28.3608  
##  NA's   :9         NA's   :9       NA's   :9        NA's   :9        
##        Mo               Cd               Sb               Pb        
##  Min.   :0.0000   Min.   : 0.000   Min.   :0.0100   Min.   :0.0000  
##  1st Qu.:0.1300   1st Qu.: 0.070   1st Qu.:0.0300   1st Qu.:0.0200  
##  Median :0.1900   Median : 0.160   Median :0.0400   Median :0.0600  
##  Mean   :0.1947   Mean   : 1.953   Mean   :0.6881   Mean   :0.1325  
##  3rd Qu.:0.2200   3rd Qu.: 0.680   3rd Qu.:0.9000   3rd Qu.:0.2000  
##  Max.   :0.7300   Max.   :31.620   Max.   :4.2000   Max.   :1.9800  
##  NA's   :40       NA's   :32       NA's   :32       NA's   :32      
##        U                 Al                 Si              P         
##  Min.   :0.00000   Min.   :   0.210   Min.   : 0.04   Min.   : 0.180  
##  1st Qu.:0.00000   1st Qu.:   2.103   1st Qu.:13.13   1st Qu.: 4.585  
##  Median :0.02000   Median :  16.025   Median :25.64   Median :10.520  
##  Mean   :0.05462   Mean   : 142.216   Mean   :24.61   Mean   :10.424  
##  3rd Qu.:0.05000   3rd Qu.: 167.548   3rd Qu.:27.76   3rd Qu.:13.865  
##  Max.   :0.66000   Max.   :2899.360   Max.   :63.05   Max.   :31.920  
##  NA's   :52        NA's   :29         NA's   :28      NA's   :24      
##        S                 Ca                  Cr               Mn         
##  Min.   :  13.54   Min.   :    0.290   Min.   :0.0000   Min.   :   0.03  
##  1st Qu.: 253.64   1st Qu.:    7.293   1st Qu.:0.0200   1st Qu.:   0.26  
##  Median : 350.41   Median :    8.500   Median :0.2900   Median :   0.50  
##  Mean   : 419.26   Mean   : 2087.841   Mean   :0.2969   Mean   :  56.40  
##  3rd Qu.: 401.96   3rd Qu.: 5276.070   3rd Qu.:0.3500   3rd Qu.:   1.38  
##  Max.   :1324.32   Max.   :20063.970   Max.   :2.7200   Max.   :2720.54  
##  NA's   :24        NA's   :27          NA's   :36       NA's   :24       
##        Fe                 Co               Ni               Cu        
##  Min.   :   0.300   Min.   :0.0000   Min.   :0.0100   Min.   : 0.030  
##  1st Qu.:   3.235   1st Qu.:0.0050   1st Qu.:0.0300   1st Qu.: 0.315  
##  Median :   5.060   Median :0.0100   Median :0.0400   Median : 0.430  
##  Mean   :  58.340   Mean   :0.2231   Mean   :0.1542   Mean   : 2.188  
##  3rd Qu.:  10.315   3rd Qu.:0.0400   3rd Qu.:0.1150   3rd Qu.: 0.635  
##  Max.   :2593.570   Max.   :6.2000   Max.   :3.0800   Max.   :59.860  
##  NA's   :25         NA's   :24       NA's   :24       NA's   :24      
##        Ti              Zn               B                   Sr        
##  Min.   :0.010   Min.   :  0.58   Min.   :    0.190   Min.   :  0.21  
##  1st Qu.:0.150   1st Qu.: 15.67   1st Qu.:    5.062   1st Qu.: 77.52  
##  Median :1.290   Median : 36.10   Median :  104.070   Median : 88.66  
##  Mean   :1.552   Mean   : 42.09   Mean   : 3417.908   Mean   : 93.20  
##  3rd Qu.:1.490   3rd Qu.: 53.19   3rd Qu.: 5670.690   3rd Qu.: 97.51  
##  Max.   :9.740   Max.   :225.48   Max.   :30304.030   Max.   :221.34  
##  NA's   :46      NA's   :24       NA's   :25          NA's   :24      
##       Sr2               Ba               K              As        
##  Min.   :  0.22   Min.   :  1.72   Min.   :0.03   Min.   :0.0100  
##  1st Qu.: 27.95   1st Qu.: 69.29   1st Qu.:2.00   1st Qu.:0.1700  
##  Median : 77.13   Median :103.81   Median :2.33   Median :0.3100  
##  Mean   : 62.90   Mean   :105.17   Mean   :2.41   Mean   :0.6043  
##  3rd Qu.: 84.30   3rd Qu.:122.97   3rd Qu.:2.67   3rd Qu.:1.1850  
##  Max.   :197.65   Max.   :402.02   Max.   :5.59   Max.   :1.9600  
##  NA's   :67       NA's   :69       NA's   :24     NA's   :28      
##        Na               Mg             O18               D         
##  Min.   : 0.050   Min.   :0.000   Min.   :-6.690   Min.   :-38.30  
##  1st Qu.: 4.470   1st Qu.:2.230   1st Qu.:-5.325   1st Qu.:-25.82  
##  Median : 6.080   Median :2.590   Median :-4.855   Median :-24.60  
##  Mean   : 6.556   Mean   :2.636   Mean   :-4.924   Mean   :-24.58  
##  3rd Qu.: 7.845   3rd Qu.:2.745   3rd Qu.:-4.625   3rd Qu.:-23.62  
##  Max.   :24.010   Max.   :6.020   Max.   :-2.440   Max.   :-10.60  
##  NA's   :24       NA's   :24      NA's   :33       NA's   :33      
##        Q              Seconds      
##  Min.   :0.00091   Min.   :     0  
##  1st Qu.:0.00128   1st Qu.: 54060  
##  Median :0.00166   Median : 99480  
##  Mean   :0.00217   Mean   : 93774  
##  3rd Qu.:0.00292   3rd Qu.:137940  
##  Max.   :0.00510   Max.   :173580  
##  NA's   :48        NA's   :48
```


So, for my imputations, it probably makes sense to do them by end member/group.

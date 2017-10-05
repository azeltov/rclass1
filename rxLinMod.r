download.file('https://www.jaredlander.com/data/acs_ny.csv',
              destfile='acs_ny.csv')

acs <- read.table('acs_ny.csv', header=TRUE, sep=',', stringsAsFactors=FALSE)

income1 <- lm(FamilyIncome ~ FamilyType + NumBedrooms + NumPeople, data=acs)

library(coefplot)
coefplot(income1, sort='mag')

library(RevoScaleR)

library(dplyr)

acs <- acs %>% 
  mutate(FamilyType=factor(FamilyType))

income2 <- rxLinMod(FamilyIncome ~ FamilyType + NumBedrooms + NumPeople,
                    data=acs, 
                    dropFirst=TRUE, coefLabelStyle="Revo")
income2
summary(income1)
summary(income2)

coefplot(income2, sort='mag')


download.file('https://www.jaredlander.com/data/manhattan_Train.csv',
              destfile='manhattan_Train.csv')


lots <- RxXdfData('lots.xdf')
rxTextToXdf(inFile='manhattan_Train.csv',
            outFile=lots,
            overwrite=TRUE, stringsAsFactors=TRUE,
            rowsPerRead=7000)

lots
head(lots)

rxGetInfo(lots)
rxSummary(~., lots)
rxSummary(~ TotalValue + FireService + LotArea, data=lots)
rxGetVarInfo(lots)
rxHistogram(~ TotalValue, data=lots)

library(dplyrXdf)

lots %>% 
  count(FireService) %>% 
  collect()

lots %>% 
  group_by(FireService) %>% 
  summarize(AvgPrice=mean(TotalValue, na.rm=TRUE)) %>% 
  collect()

value1 <- rxLinMod(TotalValue ~ LotArea + FireService + HistoricDistrict,
                   data=lots)
coefplot(value1, plot=FALSE)
class(value1)
summary(value1)
coefplot(value1, sort='mag')

rxPredict

tail(head(acs, n=4), n=1)
acs %>% head(n=4) %>% tail(n=1)

lots <- lots %>% 
  mutate(AreaCentered=LotArea - mean(LotArea, na.rm=TRUE)) %>% 
  persist(lots)

head(lots)

value2 <- lots %>% 
  # mutate(AreaCentered=LotArea - mean(LotArea, na.rm=TRUE)) %>% 
  rxLinMod(TotalValue ~ FireService + HistoricDistrict + AreaCentered, data=.)

coefplot(value2, sort='mag')

rxPredict(modelObject=value1, data=lots, outData=lots, overwrite=TRUE, 
          type='response', computeResiduals=TRUE, 
          predVarNames='Fitted', residVarNames='Resids')
head(lots)


rxPredict(modelObject=value2, data=lots, outData=lots, overwrite=TRUE, 
          type='response', computeResiduals=TRUE,
          predVarNames='Fitted2', residVarNames='Resids2')
head(lots)

rxSetComputeContext(RxLocalParallel())
value3 <- lots %>% 
  # mutate(AreaCentered=LotArea - mean(LotArea, na.rm=TRUE)) %>% 
  rxLinMod(TotalValue ~ FireService + HistoricDistrict + AreaCentered, data=.)
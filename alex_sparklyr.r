install.packages("sparklyr")
library(sparklyr)
spark_install(version = "2.1.0")
library(dplyr)

devtools::install_github("rstudio/sparklyr")

sc <- spark_connect(master = "local")

install.packages(c("nycflights13", "Lahman"))

library(dplyr)
iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

flightsTbl <- copy_to(dest=sc, df=nycflights13::flights, name="flights")
class(flightsTbl)

ncol(flightsTbl)
nrow(flightsTbl)

flightsTbl %>% 
  group_by(origin) %>% 
  summarize(AvgDelay=mean(dep_delay))

head(flightsTbl)

mod1 <- ml_linear_regression(x=flightsTbl, response = 'dep_delay', 
                             features = c('month', 'day', 'dep_time'))

mod1

summary(mod1)
class(mod1)


mod2 <- ml_linear_regression(x=flightsTbl, response = 'dep_delay', 
                             features = c('month', 'day', 'dep_time', 'origin'))
mod2
summary(mod2)

# NO PENALTY
mod3 <- ml_linear_regression(x=flightsTbl, response = 'dep_delay', 
                             features = c('month', 'day', 'dep_time', 'origin'),
                             alpha=1)
summary(mod3)



myHadoopCluster <- RxSpark()
rxSetComputeContext(myHadoopCluster)

rxHadoopMakeDir("/SampleData")
getwd()

library(sparklyr)
library(dplyr)
sc <- spark_connect(master = "local")

flightsTbl <- copy_to(dest=sc, df=nycflights13::flights, name='flights', memory=TRUE)

class(flightsTbl)
flightsTbl

ncol(flightsTbl)
nrow(flightsTbl)

flightsTbl %>% 
  group_by(origin) %>% 
  summarize(AvgDelay=mean(dep_delay))

head(flightsTbl)

mod1 <- ml_linear_regression(x=flightsTbl, 
                             response='dep_delay',
                             features=c('month', 'day', 'dep_time')
)

mod1
summary(mod1)
class(mod1)

mod2 <- ml_linear_regression(x=flightsTbl, 
                             response='dep_delay',
                             features=c('month', 'day', 'dep_time', 'origin')
)

mod2
summary(mod2)


mod3 <- ml_linear_regression(x=flightsTbl, 
                             response='dep_delay',
                             features=c('month', 'day', 'dep_time', 'origin'),
                             alpha=1
)

mod3
summary(mod3)

R.version
dplyr::db_drop_table(sc, 'flights')

spark_disconnect(sc)

rxSparkConnect()

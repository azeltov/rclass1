#DOES NOT WORK!!!!

library(RevoScaleR)
library(sparklyr)
library(dplyr)

Sys.setenv("SPARK_HOME"="/dsvm/tools/spark/spark-2.1.1")
# Connect to Spark using rxSparkConnect, specifying 'interop = "sparklyr"'
# this will create a sparklyr connection to spark, and allow you to use
# dplyr for data manipulation. Using rxSparkConnect in this way will use
# default values and rxOptions for creating a Spark connection, please
# see "?rxSparkConnect" for how to define parameters specific to your setup
cc <- rxSparkConnect(reset = FALSE, interop = "sparklyr")

# The returned Spark connection (sc) provides a remote dplyr data source 
# to the Spark cluster using SparlyR within rxSparkConnect.
sc <- rxGetSparklyrConnection(cc)

# Next, load mtcars in to Spark using a dplyr pipeline
mtcars_tbl <- copy_to(sc, mtcars)
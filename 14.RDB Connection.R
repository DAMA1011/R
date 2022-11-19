# ODBC : Query Data ####
library(DBI)
library(RMySQL)
library(dplyr)

# SQL -> download csv --> R / Python
# SQL -> R / Python  實務上都用這個

# MySQL

# start connection
conn_DB <- dbConnect(drv = RMySQL::MySQL(), 
                     host = "XXXXXXXXXXXXXXXXXXXXXX.amazonaws.xxx", 
                     username = "admin", 
                     password = "abcdefg")

# query data
df <- dbGetQuery(
    conn_DB,
    "select V.video_id,
	          V.video_title,
	          V.rating,
	          V.year,
	          IG.id,
	          IG.genre,
	          II.score,
	          II.country
	   FROM sap_id.d_video V
	   join bi_strategy.genre IG
	     on V.id = IG.id
	   join bi_strategy.info II
	     on V.id = II.id;")  # 第一個連線資訊，第二個下 SQL 指令

head(df)

# write to DB
dbWriteTable(conn_DB,"video_info",df,append =TRUE,row.names=FALSE)

# Stop connection
dbDisconnect(conn_DB)


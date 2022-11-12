# 7. Data Structure ####
# 7-1 Structure variables  ####
names(iris)
View(iris)
str(iris)

#(1)Structure one data
#取出內建資料集 iris 第一筆觀測值的第五個變數（Species）的值：
iris[1, 5]
iris[1, "Species"] # 建議直接寫明變數名稱

#(2)structure multiple variables
#透過指定 [m, n] 中的索引值取出前六個觀測值與其中三個變數：
iris[1:6, c("Sepal.Length", "Petal.Length", "Species")]

#(3)利用邏輯值判斷選擇部分的資料框
attach(iris)
iris[Petal.Length >= 6, c("Sepal.Length", "Petal.Length", "Species")] # 給予邏輯判斷塞選

#use "&（and）" or "|（or）"
filter <- (iris$Petal.Length >= 6) & (iris$Sepal.Length >= 7.5)
iris[filter, c("Sepal.Length", "Petal.Length", "Species")]

iris[Petal.Length >= 6 & Sepal.Length >= 7.5, c("Sepal.Length", "Petal.Length", "Species")]                              
detach(iris)
#*****************************************************************
# 7-2 Quiz ####
#(1)inpute “customer.csv” (3.Data_IO 資料夾)
#(2)第5筆觀測值的第3個變數（age）的值：
#(3)篩選出customer.csv第10到第20筆個案
#(4)透過指定 [m, n] 中的索引值取出10~20個觀測值與其中三個變數(gender, income, age)
#(5)取出income >= 100的觀測值, 與變量為”income”, “gender” , “age”的變數
#(6)取出income 介於20 – 50之間, 且gender為man(0)的觀測值, 並選擇變量為”gender”和 “age”的變數。最後依income進行由小至大的排序
#hint: use  “&（and）” or “|（or）”   “order() or arrange()”
attach(data)
data <- read.csv("C:/R training/3.Data_IO/customer.csv", header=T, sep=",", stringsAsFactors=F)
data

data[5,"age"]

data[10:20,]

data[10:20, c("gender", "income", "age")]

data[income >= 100, c("gender", "income", "age")]

library(dplyr)
best_man <- data[(income >= 20 & income <= 50) & (gender == 0), c("gender", "income", "age")] %>% arrange(income)
best_man
detach(data)
#***********************************************************
# 7-3 Delete variables ####
nba <- data.frame(team_name=c("Chicago Bulls", "Golden State Warriors"),
                  wins=c(72, 73),
                  losses=c(10, 9), 
                  is_champion=c(TRUE, FALSE), 
                  season=c("1995-96", "2015-16"))
nba

#delete "is_champion"
nba$is_champion <- NULL   
nba

#delete "team_name
nba <- nba[, -c(1:2)]
nba
nba[, -1]

#*********************************************************
# 7-4 subset() ####
#7-4-1 Example ####
manager <- 1:5
date <- c("02/24/18", "03/28/18", "01/1/18", "03/12/18", "01/01/18")
country <- c("US","US","UK","UK","UK")
gender <- c("M", "F", "F", "M", "F")
age <- c(32,45,25,39,99)
q1 <- c(5,3,3,3,2)
q2 <- c(4,5,5,3,2)
q3 <- c(5,2,5,4,1)
q4 <- c(5,5,5,NA,2)
q5 <- c(5,5,2,NA,2)
leadership <- data.frame(manager, date, country, gender, age, 
                         q1, q2, q3, q4, q5)

leadership

#select age >= 40 or age < 30, variabes (age, q1, q2, q3, q4)
newdata <- subset(leadership, age >= 40 | age < 30,
                  select = c(age, q1, q2, q3, q4))
newdata

#select man and age >25, column 4 to 9
newdata2 <- subset(leadership, gender =="M" &  age > 25,
                   select = 4:9)
newdata2

#************************************************************
# 7-4-2 Quiz ####
#(1)inpute "customer.csv"
#(2)select pets_dogs >= 1 & pets_cats >= 1, column (gender, age, pets_dogs, pets_cats)
#想瞭解同時養狗和養貓的人
#(3)Select "gender = 1(female) and edcat = 5 " and "pets_cats >= 1| pets_dogs >=1"
# 想瞭解高學歷女性，喜歡養狗或養貓的為何?
attach(data)
data <- read.csv("C:/R training/3.Data_IO/customer.csv", header=T, sep=",", stringsAsFactors=F)
data

data2 <- subset(data, pets_dogs >= 1 & pets_cats >= 1, select = c(gender, age, pets_dogs, pets_cats))
data2

data3 <- subset(data,(edcat == 5 & gender == 1) & (pets_dogs >= 1 | pets_cats >= 1), select = c(gender, edcat, pets_dogs, pets_cats))
data3

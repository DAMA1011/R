library(tidyverse)
video.info.ori <- read.csv(file = 'C:/R training/test/youtube.csv', stringsAsFactors = F)

video.info.des <- video.info.ori[,c("channelTitle","description")]

# Remove symbols ####
my.symbols <- c("《", "》", "【", "】", "|", "(",")",
                "®", "\n", "？", "@", "#", "?", "！", "!",
                "►","?",":","/","+","-","：", "+", "，", "▶", "*", "。", "?")
video.info.des$des_n <- gsub(paste(my.symbols, collapse = "|"),#  |或，代表所有標點符號任一
                           "", 
                           video.info.des$description)

# gsub() R語言中的函數用於從字符串中替換一個模式的所有匹配項。如果未找到模式，則字符串將按原樣返回。

# paste() 將任意数量的参數组合在一起，collapse - 用於消除兩個字符串之間的空間

# Remove stopwords ####
my.stop.words <- c(
  "娘娘", "Alizabeth", "阿辰師", "Joeman", "老高與小茉 Mr & Mrs Gao", "愛莉莎莎", 
  " Alisasa", "AM : PM早晚幹什麼","展瑞", "展榮", "K.R Bros", "展榮", "Vlog",
  "的", "你", "我", "他", "我們","他們", "他們", "影片", "頻道", "訂閱", 
  "文森說書","文森", "說書","為什麼", 
  "[:blank:]", "[:alnum:]", "[:punct:]", "[A-z0-9]")
# \d: 數字，等於 [0-9]
# \D: 非數字，等於 [^0-9]
# [:lower:]: 小寫字，等於 [a-z]
# [:upper:]: 大寫字，等於 [A-Z]
# [:alpha:]: 所有英文字，等於 [[:lower:][:upper:]] or [A-z]
# [:alnum:]: 所有英文字和數字，等於 [[:alpha:][:digit:]] or [A-z0-9]
# \w: 文字數字與底線，等於 [[:alnum:]] or [A-z0-9]
# \W: 非文字數字與底線，等於 [^A-z0-9_]
# [:blank:]: 空白字元，包括空白和tab
# \s: 空白字元,
# \S: 非空白字元
# [:punct:]: 標點符號 ! " # $ % & ’ ( ) * + , - . / : ; < = > ? @ [ ] ^ _ ` { | } ~.

video.info.des$des_n <- gsub(paste(my.stop.words, collapse = "|"),
                           " ",
                           video.info.des$des_n)

# 結巴斷詞 ####
library(jiebaR)
wk <- worker(stop_word = jiebaR::STOPPATH) # Initialize a JiebaR worker

# Add customized terms ####
customized.terms <- c("台灣", "義大利", "法國", "小彤姐", "不只是", "嘆為觀止", "麵包", "攏吼蕊啦")
new_user_word(wk, customized.terms)

# https://weijutu.github.io/2019/04/17/r/r-textmining-01-ch01-1/

# segment terms and separate by blank 
video.description.des <- tibble(
  channel_title = video.info.des$channelTitle, # Youtube channel title
  description = sapply(                    # 餵list，依據指定的函數來一項一項運算，再回傳一個 vector。
    as.character(video.info.des$des_n),
    # vector to be segmented
    function(char) segment(char, wk) %>% paste(collapse = " ") # segment function
  )
)

# tidy text ####
# one token per row
library(tidytext)
tidy.description.des <- video.description.des %>%
  unnest_tokens(word, description, token = function(t) str_split(t,"[ ]{1,}")) # 至少要有一個空白鍵

# str_split() https://blog.csdn.net/weixin_46587777/article/details/124912225

tidy.description.des <- tidy.description.des[nchar(tidy.description.des$word) > 1, ]

# nchar() R編程中的方法用於獲取字符串的長度。

# 詞頻分析 ####
channel.words.des <- tidy.description.des %>%
  group_by(channel_title , word) %>% 
  summarise(word_frequency =  n()) %>%
  group_by(channel_title) %>%
  top_n(3, word_frequency) %>% 
  arrange(-word_frequency)

# n=n() means that a variable named n will be assigned the number of rows in the summarized data

# TF-IDF ####
video.words <- tidy.description.des %>%   # 在每個cannel裡個詞的次數
  group_by(channel_title , word) %>% 
  dplyr::summarise(word_frequency =  n()) %>%
  ungroup()

total.count <- tidy.description.des %>%  # 在所有文本裡各個詞的次數
  group_by(word) %>% 
  dplyr::summarise(total_count = n())  # 指定 dplyr 的 summarise

# select top 10 tf-idf key-words
tiidf.words <- video.words %>%
  left_join(total.count, by = "word") %>%
  bind_tf_idf(word, channel_title, word_frequency) %>%
  filter(nchar(word) > 1) %>%
  group_by(channel_title) %>%
  top_n(10, tf_idf) %>% 
  arrange(channel_title,-tf_idf)


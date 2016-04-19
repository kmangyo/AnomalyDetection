library(data.table)
library(dplyr)
library(compiler)
library(ggplot2)
library(zoo)
library(stringi)

# 예시 데이터는 구글 트랜드에서 선풍기, 도시락, 냉장고, 목도리 키워드의 쿼리 수 추이를 사용하였음. 
# 구글에선 해당 쿼리 추이를 지정된 기간에서 제일 높았던 시점을 100으로 하여 해당 키워드의 쿼리 추이 수치를 주차별로 제공.
# 비교적 계절적 특성을 갖고 있는 쿼리이기 때문에 선택.

trend_data<- read.csv(file.choose(), sep=',', row.names = NULL, stringsAsFactors = FALSE, skip=4)
trend_data$seq<-1
trend_data$seq<-cumsum(trend_data$seq)
trend_data<-subset(trend_data,seq<=642)

trend_data$선풍기<-as.numeric(trend_data$선풍기)
trend_data$도시락<-as.numeric(trend_data$도시락)
trend_data$냉장고<-as.numeric(trend_data$냉장고)
trend_data$목도리<-as.numeric(trend_data$목도리)

trend_data$week<-stri_sub(trend_data$주,1,10)
trend_data$week<-as.Date(trend_data$week)

# 이 중 목도리 키워드를 사용해서 이상치 측정을 구현, 해당 키워드를 수집한 데이터에 따라 변경하여 사용할 수 있음.
keyword<-c('목도리')
trend_data_key<-trend_data[c('week',keyword,'seq')]
names(trend_data_key)[2]<-c('keyword')

# w 는 현재 시점 (t시점)에서 측정된 수치의 영향력을 의미 
# 만약 w가 높으면, 현재 시점에 측정된 수치의 영향력은 낮아짐
w<- 0.05

# 첫 EMA (Exponential Moving Average) 는 최초 4주 동안의 평균을 사용 
# 또한, 첫 EMS (Exponential Moving Standard Deviation) 는 최초 4주 동안의 S.D을 사용 

mean<-rollapply(trend_data_key[,c('keyword')], 4, mean)
sd<-rollapply(trend_data_key[,c('keyword')], 4, sd)

trend_data_EM<-subset(trend_data_key, seq>=4)

trend_data_EM$EMA<-NA
trend_data_EM$EMS<-NA
trend_data_EM[1,c('EMA')]<-mean[1]
trend_data_EM[1,c('EMS')]<-sd[1]

trend_data_EM<-data.table(trend_data_EM)

# EMA를 계산하는 함수
fn_EMA <- function(t, EMA) {
  for(i in seq_along(EMA)[-1]) {
    EMA[i] <- w * EMA[i - 1L] +  (1-w) * t[i]
  }
  EMA
}

fn_EMA <- cmpfun(fn_EMA)

trend_data_EM[, EMA := fn_EMA(keyword, EMA)]

# EMS를 계산하는 함수
fn_EMS <- function(t, EMS) {
  for(i in seq_along(EMS)[-1]) {
    EMS[i] <- sqrt(w * EMS[i - 1L]^2 + (1-w) * (t[i]-trend_data_EM$EMA[i])^2)
  }
  EMS
}

fn_EMS <- cmpfun(fn_EMS)

trend_data_EM[, EMS := fn_EMS(keyword, EMS)]

# n 은 S.D의 갯수를 의미. 해당 값이 클수록 둔감하게 이상치를 측정.
trend_data_EM<-data.frame(trend_data_EM)
n<-1
trend_data_EM$alarm <- abs(trend_data_EM[,c('keyword')]-trend_data_EM$EMA) > n * trend_data_EM$EMS

# 전체 기간동안의 시계열 데이터와 이상치로 측정된 시점을 표기하는 plot
ggplot(subset(trend_data_EM), aes(x = week, y= keyword)) + 
  geom_point(aes(colour=factor(alarm), size=10)) + geom_line(aes(y = keyword), colour="black")

# 특정 기간동안의 시계열 데이터와 이상치로 측정된 시점을 표기하는 plot
 ggplot(subset(trend_data_EM,seq<=641 & seq>=541), aes(x = week, y= keyword)) + 
  geom_point(aes(colour=factor(alarm), size=10)) + geom_line(aes(y = keyword), colour="black") 

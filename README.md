# AnomalyDetection
Anomaly detection in time-series data

목적: 
시계열 데이터에서 이상치를 측정

데이터: 
구글트랜드(https://www.google.com/trends/?hl=ko)에서 제공하는 개별 키워드의 쿼리 데이터

방법: 

1) 최근 데이터에 가중치를 주는 EMA(Exponential Moving Average)와 EMS(Exponential Moving Standard Deviation)를 사용하여, 일정 편차를 넘어서는 값을 이상치로 추정

(출처: https://medium.com/@iliasfl/data-science-tricks-simple-anomaly-detection-for-metrics-with-a-weekly-pattern-2e236970d77#.qr5894fe2)

2) 아이디어의 구현은 R을 활용

예시:
아래 그림은 '목도리' 키워드의 구글 주차별 쿼리 추이
![alt tag](https://dl.dropboxusercontent.com/u/1049842/%EB%B8%94%EB%A1%9C%EA%B7%B8/anomalydetection/scarf_full.png)

아래 그림은 '목도리' 키워드에서 이상치를 측정한 쿼리 추이, 푸른색 포인트는 이상치를 의미. 붉은색 포인트는 비이상치
![alt tag](https://dl.dropboxusercontent.com/u/1049842/%EB%B8%94%EB%A1%9C%EA%B7%B8/anomalydetection/scarf_detection.png)

아래 그림은 위의 그림에서 특정 기간(2014-6-15~2016-04-10)으로 확대하여 이상치 부분을 살펴본 그림
![alt tag](https://dl.dropboxusercontent.com/u/1049842/%EB%B8%94%EB%A1%9C%EA%B7%B8/anomalydetection/scarf_zoom.png)

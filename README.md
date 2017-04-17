# 2016.M3.TQF-ML.relative-stock-price-prediction-by-multi-factor-model

This project would try to predict the stock return relative to market index by SVM method.


Project Goal

Try
to predict whether the stock price would go up or down compared to the stock
index, for example Shanghai Composite Index. The multi-factor model is popular
in stock price prediction, however the linear model is not efficient sometimes.
So I would like to apply some other machine learning methods to see whether it
would work more efficient.

Date Sources:
Wind Financial Database

Method:
Mainly SVM and Logistic regression. PCA and linear regression may be used to filtrate
the factors.

More Details:
1.
Choose an index and find the stocks which compose the index. And try to obtain
the data of as many factors as I can.
2.
Select some effective factors by linear regression or PCA.
3.
Define two states of stock return, better than the market index and worse than
the market index. Apply SVM and Logistic regression to carrying out the
classification.
4.
Check the accuracy of the method. If it’s accurate, try to apply it to the
futures market. If not, try to find why the linear factor model is still
better.


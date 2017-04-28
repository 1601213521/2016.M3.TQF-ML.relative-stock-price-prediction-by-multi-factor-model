## 2016.M3.TQF-ML.relative-stock-price-prediction-by-multi-factor-model

### Project Description
This project would try to predict the stock return relative to market index by SVM method. Absolute stock price prediction is difficult and senseless, however relative stock return's prediction may be feasible and there are many relavant researches. After reading several analysis reports about multi-factor model, I chose 13 factors from the reports to do this analysis. Next I make the predition by SVM method and find some pattern, and then set up a simple strategy to show the usefulness of the pattern. See the [proposal](Proposal.pdf).


### Step Process and Main Result
First of all, before implement the analysis, I have to check the efficiency of these factors I selecte. I compute the IC ratio and check the form of monotony, which are common methods to check the efficiency of single factor. The results show that the IC ratios of most of factors selected are significant and several are bigger than 4% or even 10% in absolute value. In addition, the monotonicity test results are also good, and the graphs present obvious monotonicity in the return on the factors. Therefore these factors can be considered efficient and I can use them for further analysis.

Secondly, I try to figure out whether SVM is a good method to predict the future return with these factors or not. As I use yearly data and have ten years data, I choose first 8-year data to test this model and try to make some improvement. For each year, I take this year's factors data with the next year's return to train the SVM model, and then take the next year's factors data with the return of two years later to test the accuracy of the prediction. The accuracy can reach 56%. Meanwhile, I carry out the same process with PCA on factors, and as a result, I find the PCA method doesn't help a lot since the accuracy doesn't increase. ( At the same time ,I also take two-year data for training and one year for prediction instead of one for training and one for prediction here, however the methods here present better result. I still test different parameters in SVM model for optimization. Finally I choose 5% of points are allowed to lie between the support vector line, since it shows better result.

Thirdly, due to the uselessness of PCA here, I use another method check and delete redundant factors. I do the same process as in the second step for 13 times and each time ignore one factor. If the test accuracy increases because of the ignorance of the factor, this factor would be deleted, otherwise it would be kept in the model. As a result, only 8 factors are left: total market value, BPS, 12-month swing, 100-week volitility, 60-day price change, 120-day price change, 240-day price change,  and account receivable.

Forth step: do the final predicion test. With all ten-year data and the rest 8 factors, by the SVM model, I get the final accuracy results, 56.7% in average.

Final step: set up a simple strategy according to the results above. As the predition accuracy is stably over 50%, we can think of a simple strategy to see whether this pattern can be used for investment. Buy all the stocks that are predicted to perform better than market in equal weights, and hold them for a whole year. As final result shows, net value of the strategy is much better than the market index. So if short selling is allowed, long all these stocks and short the market index ETF may be a good chance to earn some money. 


### Features/Factors
total market value
EPS
BPS
12-month swing
100-week volitility
3-year net income growth
3-year revenue growth
60-day price change
120-day price change
240-day price change
operating income
total current assets
account receivable

### Methods
Mainly use SVM model, and PCA is used.

### Data
I get the data from Wind financial database, and do the data processing in MATLAB and save them as Excel files. Here in each data file, there are one year's factors data of all firms and the following year's return data.

As the data period is from 2005 to 2015, I just choose the firms which are listed before 2005. Then those firms without complete data of these factors selected are deleted from the samples, and 1037 stocks left. So there is data of ten years (2005-2015), and 1037 samples in each year.

### Implementation
* [Python notebook file: Stock price prediction by multi factor model](Stock price prediction by multi factor model.ipynb)

### Conclusion
The SVM, with the 13 factors above, is effective to predict the stock relative return compared to CSI 800 index, with the average accuracy about 56%. And the strategy based on the prediction can be profitable.

% without the account of wind, this m file cannnot run. 
% as the data obtained in this file has been saved in 'Stock.mat', we can
% directly run the m file 'SVMcalculation.m'

load('StockCodes0.mat');  % stock codes listed before 2005
StartTime='2005-12-31';
EndTime='2015-12-31';

w=windmatlab;
% get the data of those 13 features
Stock={};
for i=1:length(StockCodes0)
    [Stock(i).data,~,Stock(i).fields,Stock(i).time,~,~]=w.wsd(StockCodes0(i),'close,pct_chg,ev,bps,eps_basic,annualstdevr_100w,growth_profit,growth_or,opprofit,tot_cur_assets,acct_rcv',StartTime,EndTime,'unit=1000000','currencyType=','N=3','rptType=1','Period=Y','Days=Alldays');
end
time_wss=20051231:10000:20151231;
for i=1:length(time_wss)
    [WssData.swing(:,i),~,WssData.fields(1),~,~,~]=w.wss(StockCodes0,'swing',strcat('tradeDate=',num2str(time_wss(i))),'cycle=Y');
    [WssData.chg60(:,i),~,WssData.fields(2),~,~,~]=w.wss(StockCodes0,'pct_chg_nd',strcat('tradeDate=',num2str(time_wss(i))),'days=-60');
    [WssData.chg120(:,i),~,WssData.fields(3),~,~,~]=w.wss(StockCodes0,'pct_chg_nd',strcat('tradeDate=',num2str(time_wss(i))),'days=-120');
    [WssData.chg240(:,i),~,WssData.fields(4),~,~,~]=w.wss(StockCodes0,'pct_chg_nd',strcat('tradeDate=',num2str(time_wss(i))),'days=-240');
end
% put the data from different sources together
for i=1:length(Stock)
    Stock(i).data=[Stock(i).data,WssData.swing(i,:)',WssData.chg60(i,:)',WssData.chg120(i,:)',WssData.chg240(i,:)']; 
    Stock(i).fields=[Stock(i).fields;WssData.fields'];    
end

% eliminate those stocks whose data is not complete
lackdata=[];
for i=1:length(Stock)
    if sum(sum(isnan(Stock(i).data)))
        lackdata=[lackdata,i];
    end
end
Stock(lackdata)=[];
StockCodes0(lackdata)=[];
StockCodes=StockCodes0;

% get the data of the market index
IndexCode='000906.SH';
Index=w.wsd(IndexCode,'close,pct_chg',StartTime,EndTime,'Period=Y','Days=Alldays');

% save the data
save('Stock.mat','Stock','StockCodes','Index','StartTime','EndTime')


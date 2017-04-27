load('Stock.mat')  % the data saved before
data_for_svm={};   % adjust the data into the form that is convenient for SVM
for j=1:size(Stock(1).data,1)-1
    temp=[];
    for i=1:length(Stock)
        temp=[temp;[Stock(i).data(j,3:end),Stock(i).data(j+1,2)]];
    end
    data_for_svm(j).data=temp;
end

%% Test the effeciency of these factors
% Compute the IC of the factors (|IC|>0.4% mean the factor is very good)
ic=[];
for i=1:length(data_for_svm)
    FactorData=data_for_svm(i).data;
    for j=1:size(FactorData,2)-1
        rho=corrcoef(FactorData(:,j),FactorData(:,end)/100);
        ic(i,j)=rho(2);
    end
end
IC=mean(ic);
disp('IC of 13 factors:');disp(IC)

% Show the monotony of these factors by graph (the more evident monotonic graph means the better factor)
FactorMonotonyTest={};
for i=1:length(data_for_svm)
    FactorData=data_for_svm(i).data;
    for j=1:size(FactorData,2)-1
        [~,order]=sort(FactorData(:,j));
        ret_factor=FactorData(:,end);
        ret_factor=ret_factor(order);
        group=floor(length(ret_factor)/10);
        GroupRetur=[];
        for k=1:9
            GroupReturn(k)=mean(ret_factor(1+(k-1)*group:k*group));
        end
        GroupReturn(10)=mean(ret_factor(1+9*group:end));
        FactorMonotonyTest(i,j)={GroupReturn};
    end
end
FactorMonotonyReturn={};
for j=1:size(FactorMonotonyTest,2)
    GroupReturnMat=cell2mat(FactorMonotonyTest(:,j));
    FactorMonotonyReturn{j}=(prod(1+GroupReturnMat/100)).^(1/10)-1;
end
bar(FactorMonotonyReturn{1});title(strcat('Factor:',Stock(1).fields(3+1-1)))
figure
bar(FactorMonotonyReturn{2});title(strcat('Factor:',Stock(1).fields(3+2-1)))
figure
bar(FactorMonotonyReturn{8});title(strcat('Factor:',Stock(1).fields(3+8-1)))
figure
bar(FactorMonotonyReturn{13});title(strcat('Factor:',Stock(1).fields(3+13-1)))

%% SVM calculation
% one year(current year) for training, one year(next year) for testing
accuracy=[];accuracy_pca=[];
for i=1:length(data_for_svm)-3
    X_train=data_for_svm(i).data(:,1:13);
    Y_train=data_for_svm(i).data(:,end);
    X_train_std=(X_train-repmat(mean(X_train),size(X_train,1),1))./(repmat(std(X_train),size(X_train,1),1));  % standardization
    Y_train=Y_train>Index(i+1,2);
    
    X_test=data_for_svm(i+1).data(:,1:13);
    Y_test=data_for_svm(i+1).data(:,end);
    X_test_std=(X_test-repmat(mean(X_test),size(X_test,1),1))./(repmat(std(X_test),size(X_test,1),1));
    Y_test=Y_test>Index(i+2,2);
    
    SVMStruct=svmtrain(X_train_std,Y_train,'kernel_function','linear','kktviolationlevel',0.05);
    g=svmclassify(SVMStruct,X_test_std);
    
    accuracy(i,1)=1-sum(abs(g-Y_test))/length(Y_test);

% % % % two years(current year and the next year) for training£¬one year(the third year) for testing and prediction.  £¨the method above has better results£©
% % % accuracy2=[];
% % % for i=1:length(data_for_svm)-2
% % %     X_train=[data_for_svm(i).data(:,1:13);data_for_svm(i+1).data(:,1:13)];
% % %     Y_train=[data_for_svm(i).data(:,end);data_for_svm(i+1).data(:,end)];
% % %     X_train_std=(X_train-repmat(mean(X_train),size(X_train,1),1))./(repmat(std(X_train),size(X_train,1),1));
% % %     %X_train_std=(X_train-repmat(min(X_train),size(X_train,1),1))./(repmat(max(X_train)-min(X_train),size(X_train,1),1));
% % %     Y_train=Y_train>Index(i+1,2);
% % %     
% % %     X_test=data_for_svm(i+2).data(:,1:13);
% % %     Y_test=data_for_svm(i+2).data(:,end);
% % %     X_test_std=(X_test-repmat(mean(X_test),size(X_test,1),1))./(repmat(std(X_test),size(X_test,1),1));
% % %     % X_test_std=(X_test-repmat(min(X_test),size(X_test,1),1))./(repmat(max(X_test)-min(X_test),size(X_test,1),1));
% % %     Y_test=Y_test>Index(i+3,2);
% % %     
% % %     SVMStruct=svmtrain(X_train_std,Y_train,'kernel_function','linear','kktviolationlevel',0.05);
% % %     g=svmclassify(SVMStruct,X_test_std);
% % %     
% % %     accuracy2(i)=1-sum(abs(g-Y_test))/length(Y_test);
% % % end

    % Try PCA
    [coef,score,latent,t2] = princomp(X_train_std);
    cum_contribution=cumsum(latent)/sum(latent);
    pn=min(find(cum_contribution>0.9));
    X_train_std_pca=score(:,1:pn);
    X_test_std_pca=X_test_std*coef;
    X_test_std_pca=X_test_std_pca(:,1:pn);
    SVMStruct=svmtrain(X_train_std_pca,Y_train,'kernel_function','linear','kktviolationlevel',0.05);
    g=svmclassify(SVMStruct,X_test_std_pca);

    accuracy_pca(i,1)=1-sum(abs(g-Y_test))/length(Y_test);

end

% eliminating redundant factors step by step
accuracy_el=[];
for i=1:length(data_for_svm)-3
    X_train=data_for_svm(i).data(:,1:13);
    X_train_std=(X_train-repmat(mean(X_train),size(X_train,1),1))./(repmat(std(X_train),size(X_train,1),1));
    Y_train=data_for_svm(i).data(:,end);   Y_train=Y_train>Index(i+1,2);

    X_test=data_for_svm(i+1).data(:,1:13);
    X_test_std=(X_test-repmat(mean(X_test),size(X_test,1),1))./(repmat(std(X_test),size(X_test,1),1));
    Y_test=data_for_svm(i+1).data(:,end);   Y_test=Y_test>Index(i+2,2);
    for j=1:size(X_train_std,2)
        X_train_std_el=X_train_std;
        X_train_std_el(:,j)=[];
        X_test_std_el=X_test_std;
        X_test_std_el(:,j)=[];
        SVMStruct=svmtrain(X_train_std_el,Y_train,'kernel_function','linear','kktviolationlevel',0.05);
        g=svmclassify(SVMStruct,X_test_std_el);
        
        accuracy_el(i,j)=1-sum(abs(g-Y_test))/length(Y_test);
    end
end
    
% ac_chg=accuracy_el-repmat(accuracy,1,size(accuracy_el,2));
ac_chg=mean(accuracy_el)-mean(accuracy);
redundant_factors=find(ac_chg>0);
rest_factors=find(ac_chg<0);

% after test, 10 factors are remained:
% total market value, EPS, BPS,12-month swing, 100-week volitility, 60-day price change, ,120-day price change, 240-day price change, total current assets, and account receivable.

accuracy_rest=[];
for i=1:length(data_for_svm)-3
    X_train=data_for_svm(i).data(:,1:13);
    X_train_std=(X_train-repmat(mean(X_train),size(X_train,1),1))./(repmat(std(X_train),size(X_train,1),1));
    Y_train=data_for_svm(i).data(:,end);   Y_train=Y_train>Index(i+1,2);

    X_test=data_for_svm(i+1).data(:,1:13);
    X_test_std=(X_test-repmat(mean(X_test),size(X_test,1),1))./(repmat(std(X_test),size(X_test,1),1));
    Y_test=data_for_svm(i+1).data(:,end);   Y_test=Y_test>Index(i+2,2);

        X_train_std_rest=X_train_std(:,rest_factors);
        X_test_std_rest=X_test_std(:,rest_factors);
        SVMStruct=svmtrain(X_train_std_rest,Y_train,'kernel_function','linear','kktviolationlevel',0.05);
        g=svmclassify(SVMStruct,X_test_std_rest);
        
        accuracy_rest(i,1)=1-sum(abs(g-Y_test))/length(Y_test);
end

%%% with the results above, we can construct an investing strategy. Buy all
%%% the stocks that are predicted to be better than the market index, and
%%% hold them for a year in equal weight.
LongPortReturn=[];
ShortPortReturn=[];
for i=1:length(data_for_svm)-1
    X_train=data_for_svm(i).data(:,1:13);
    X_train_std=(X_train-repmat(mean(X_train),size(X_train,1),1))./(repmat(std(X_train),size(X_train,1),1));
    Y_train=data_for_svm(i).data(:,end);   Y_train=Y_train>Index(i+1,2);

    X_pred=data_for_svm(i+1).data(:,1:13);
    X_pred_std=(X_pred-repmat(mean(X_pred),size(X_pred,1),1))./(repmat(std(X_pred),size(X_pred,1),1));

    X_train_std_rest=X_train_std(:,rest_factors);
    X_pred_std_rest=X_pred_std(:,rest_factors);
    SVMStruct=svmtrain(X_train_std_rest,Y_train,'kernel_function','linear','kktviolationlevel',0.05);
    g=svmclassify(SVMStruct,X_pred_std_rest);
    long=find(g);
    short=find(g==0);
    ret=data_for_svm(i+1).data(:,end);
    long_ret=ret(long);
    short_ret=ret(short);
    LongPortReturn(i+1)=mean(long_ret);
    ShortPortReturn(i+1)=mean(short_ret);
    
end

% Visulize the net value changing process compared to the market index
Index_chg=Index(2:end,2)';
netvalue_Long=[1,cumprod(1+LongPortReturn(2:end)/100)]';
netvalue_Index=[1,cumprod(1+Index_chg(2:end)/100)]';
figure
plot(Stock(1).time(2:end),[netvalue_Long,netvalue_Index])
legend('LongPortReturn','IndexReturn')

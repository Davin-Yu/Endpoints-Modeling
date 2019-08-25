% Create a varaible named 'Data' and copy the 'EDModel_Study2_Head_2019' or
% 'EDModel_Study2_Hand_2019' sheet from the excel file into this variable
% (not include the first line)
[M, N] = size(Data);
Data(:,N+1) = 1; % Initialization
% Data Pre-processing
for d = (10:5:35)
    for z = (100:200:500)
        for col = (2:4) %x, y, Time column
            tar = Data(:,6)==d & Data(:,8)==z;
            meanP = mean(Data(tar, col));
            stdP = std(Data(tar, col));
            Data(tar & Data(:, col) > meanP + 3 * stdP, N+1) = 0;
            Data(tar & Data(:, col) < meanP - 3 * stdP, N+1) = 0;
        end
    end
end
delNum = M - sum(Data(:,N+1));

%Structure Initialization
ifNorm_X = [];      ifNorm_Y = [];
normSigma_X = [];   normSigma_Y = [];
normMu_X = [];      normMu_Y = [];
corr = [];
time = [];
allDataNum = [];    errorNum = [];
combNum = 18;    %Number of A * D combination

%Analysis
for i = 1:round(M/20)
    list = (i-1)*20+1:(i)*20;
    L_X = Data(list,2);   L_Y = Data(list,3);  
    L_Time = Data(list,4);  L_Error = Data(list, 9);
    keep = Data(list,N+1);
    list_X = L_X(keep==1,1);             list_Y = L_Y(keep==1,1);
    list_Time = L_Time(keep==1,1);       list_Error = L_Error(keep==1,1);
    %Correlation coefficient
    R = corrcoef(list_X, list_Y);
    %Standarlization and Normality Test
    listNorm_X = (list_X-mean(list_X))/std(list_X);   listNorm_Y = (list_Y-mean(list_Y))/std(list_Y);
    ksResult_X = kstest(listNorm_X);                ksResult_Y = kstest(listNorm_Y);
    %Normality Test and MLE
    phat_X = mle(list_X);                   phat_Y = mle(list_Y);
    posI = ceil(i/combNum);           
    posJ = mod(i-1,combNum)+1;
    ifNorm_X(posI, posJ) = ksResult_X;      ifNorm_Y(posI, posJ) = ksResult_Y;
    normSigma_X(posI, posJ) = phat_X(2);    normSigma_Y(posI, posJ) = phat_Y(2);
    normMu_X(posI, posJ) = phat_X(1);       normMu_Y(posI, posJ) = phat_Y(1);
    corr(posI, posJ) = R(1, 2);
    time(posI, posJ) = mean(list_Time);
    allDataNum(posI, posJ) = size(list_Error, 1); errorNum(posI, posJ) = sum(list_Error);
end
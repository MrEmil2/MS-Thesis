%% Training

% Train Net
% testnet6 = trainnet(trainDS,net_1,"crossentropy",options6);

% re-shape the true values of the test dataset
% YTrue=readall(testDS);
% YTrue=YTrue(:,2);
% YTrue=cat(1,YTrue{:});
%% Testing

% Test Net
test7AN = minibatchpredict(testnet7AN,testDS);

[~, idx] = max(test7AN, [], 2);           % select the class with the highest predicted score
YPred = categorical(idx, 1:6, cats);

accur1 = mean(YPred(:) == YTrue(:))
confusionchart(YTrue(:),YPred(:))
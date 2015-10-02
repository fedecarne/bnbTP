%%
%{
Usage:
%}

clear; clc;

%% (1) Initialize things 
bnbTP_initialize;

%% (2) Register images
bnbTP_register;

%% () Register z stack
bnbTP_zstack;

zstackView;

%% (3) Define ROI's
bnbTP_rois;

%% 
roisPlot();

%% (4) Extract fluorescence
bnbTP_extract2;

%% (5) Clean temporary files in BnB
bnbTP_clean;

%% Concatenate all times
F  = [traces(:).roisTrace];
t  = [traces(:).frameTimeStamps];
plot(t,F')

imagesc(F(:,1:20000))

a={traces(:).roisTrace}';
s = cellfun('length',a);
n_neurons = size(a{1,1},1);

imagesc(a{2,1})

%% infer spike trains
V.dt = 1/40;
cell_i = 1;
[n_best P_best V C]=fast_oopsi(F(cell_i,:),V);

figure
hold on
plot(F(1,:)'/2000)
plot(n_best)


%svmtrain
%logistic regression 
%Naive Bayes classifier





%% This code extracts weights using HCP task-fmri dataset with
% flm: Functionally local mesh 
% slm: Spatially local mesh
% fmm: Functional mesh model
% lmm: Local mesh model
% fc: Functional connectivity

% In order to run classify_with_nested_cv, you need to add liblinear-2.1 to
% your path. You may need to run make.m under 'liblinear-2.1/matlab/'
% folder and rename the generated mex files as train_linear and
% predict_linear instead of train and predict, respectively.
addpath(genpath('../liblinear-2.1'));

experiment = 'lmm';
% if p_list, lambda_list and c_list are not specified, default values
% will be used
p_list = [5]; 
lambda_list = [32];
c_list = [0.1, 1, 10];

% Extract weights for flm, slm, fmm, lmm or fc
extract_weights(experiment, p_list, lambda_list);
% Results are written under folder [experiment '_weights']

% Classify weights with nested cross validation
%classify_with_nested_cv(experiment, p_list, lambda_list, c_list);
% Classification results are written under folder 'classification_results'
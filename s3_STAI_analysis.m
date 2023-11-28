%% Code to analyse parental STAI-S change scores
% Author: Marianne van der Vaart
% Date: October 2023

% Analyse change in parental anxiety following a heel lance as part of the
% Petal trial.

% This code makes use of the Permutation Analysis of Linear Models (PALM) tool (Winkler et al, 2014),
% available through https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM or
% https://github.com/andersonwinkler/PALM.
% 
% PALM Citation: Winkler AM, Ridgway GR, Webster MA, Smith SM, Nichols TE. Permutation inference for the general linear model. NeuroImage, 2014;92:381-397 

%% Set up design matrix
dataFolder = './data';
load([dataFolder,'/data_raw/Parental_STAI'])

T = T_Parental_STAI;
T.diff_outcome = T.outcome - T.baseline; % get STAI-S change score

% create design matrix with mean, baseline STAI and parent variable
% (mother/father)
predictor = ones(length(T.diff_outcome), 1); 
X = cat(2, ...
            predictor, ...
            T.baseline,...
            T.parent);

% define y (outcome)
y = T.diff_outcome;

% define X (design matrix)
nanind = (isnan(y)); y(nanind) = []; X(nanind, :) = []; % remove missing values
X(:,2) = X(:,2) - mean(X(:,2)); % demean the baseline covariate
X(:,3) = X(:,3) - mean(X(:,3)); % demean the parent parent covariate

%% Contrast 1: mean and baseline only
% -------------------------------------
% fit linear model model with mean and baseline only (parametric)
mdl = fitlm(X(:,1:2), y, 'RobustOpts', 'off','intercept',false); 

% check residuals for normality
[~, p_norm1] = lillietest(mdl.Residuals.Raw, "Distr", "norm");

% fit model (non-parametric)
c = [1 0 ; 0 1]; % set contrasts

csvwrite('tmpPalm_y.csv',y)
csvwrite('tmpPalm_x.csv', X(:,1:2))
csvwrite('tmpPalm_t.csv', c)

palm -i tmpPalm_y.csv...
    -d tmpPalm_x.csv...
    -t tmpPalm_t.csv...
    -n 10000 ...
    -ise ...
    -o tmpPalm ...
    -twotail ...
    -saveglm ...
    -quiet

cope = []; tstat = []; pval = []; 
for iContrast = 1:length(c)
    cope(iContrast) = readmatrix(['tmpPalm_dat_cope_c',num2str(iContrast),'.csv']);
    tstat(iContrast) = readmatrix(['tmpPalm_dat_tstat_c',num2str(iContrast),'.csv']);
    pval(iContrast) = readmatrix(['tmpPalm_dat_tstat_uncp_c',num2str(iContrast),'.csv']);
end

t_perm.STAISchange_cope_nonparametric = cope; 
t_perm.STAISchange_tstat_nonparametric = tstat; 
t_perm.STAISchange_pval_nonparametric = pval; 

delete('tmpPalm*')

save([dataFolder,'/parental_STAI_contrast1.mat'],'t_perm','p_norm1')


%% Contrast 2: mean, baseline and parent
% ----------------------------------------
clear t_perm p_norm1

% fit model with mother/father variable (parametric)
mdl = fitlm(X(:,1:3), y, 'RobustOpts', 'off','intercept',false); 

% check residuals for normality
[~, p_norm2] = lillietest(mdl.Residuals.Raw, "Distr", "norm");

% fit model (non-parametric)
c = [1 0 0; 0 1 0; 0 0 1]; % set contrasts

csvwrite('tmpPalm_y.csv',y)
csvwrite('tmpPalm_x.csv', X(:,1:3))
csvwrite('tmpPalm_t.csv', c)

palm -i tmpPalm_y.csv...
    -d tmpPalm_x.csv...
    -t tmpPalm_t.csv...
    -n 10000 ...
    -ise ...
    -o tmpPalm ...
    -twotail ...
    -saveglm ...
    -quiet

cope = []; tstat = []; pval = []; 
for iContrast = 1:length(c)
    cope(iContrast) = readmatrix(['tmpPalm_dat_cope_c',num2str(iContrast),'.csv']);
    tstat(iContrast) = readmatrix(['tmpPalm_dat_tstat_c',num2str(iContrast),'.csv']);
    pval(iContrast) = readmatrix(['tmpPalm_dat_tstat_uncp_c',num2str(iContrast),'.csv']);
end

t_perm.STAISchange_cope_nonparametric = cope; 
t_perm.STAISchange_tstat_nonparametric = tstat; 
t_perm.STAISchange_pval_nonparametric = pval; 

delete('tmpPalm*')

save([dataFolder,'/parental_STAI_contrast2.mat'],'t_perm','p_norm2')
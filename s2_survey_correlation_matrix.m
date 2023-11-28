%% Code to produce correlation matrix & hierarchical clustering
% Author: Luke Baxter & Marianne van der Vaart
% Date: October 2023

% Analyse survey data collected as part of the Petal trial by making a hierarchical clustering plot & correlation matrix. 
% Produces figures 2C. Data requests should be made to the PI of the Petal Trial.

% Petal trial protocol: Cobo MM, Moultrie F, Hauck AGV, et al Multicentre, randomised controlled trial to investigate 
% the effects of parental touch on relieving acute procedural pain in neonates (Petal) BMJ Open 2022;12:e061841. 
% doi: 10.1136/bmjopen-2022-061841

% This code makes use of Colorbrewer
% (https://github.com/DrosteEffect/BrewerMap). 
% Colorbrewer citation: Stephen23 (2023). ColorBrewer: Attractive and Distinctive Colormaps (https://github.com/DrosteEffect/BrewerMap/releases/tag/3.2.3), GitHub. Retrieved November 24, 2023.

%% Load data
dataFolder = './data';

T = readtable([dataFolder,'/data_raw/DatasetQ4.csv']);
Dataset_key = readtable([dataFolder,'/data_raw/survey-key'],"Delimiter" , ","); 
T.Properties.VariableNames = Dataset_key{38:47,2};

variable_names = T.Properties.VariableNames;
data = table2array(T);
num_variables = size(data,2);
nmap = flipud(brewermap(25,'RdBu'));

%% Perform cluster analysis on correlation matrix 

% zscore data
data_zscore = zscore(data); 

% correlation matrix 
correlationMatrix = corr(data_zscore); 

% maximum correlation
correlationMatrix_maxValue = max(max(abs(tril(correlationMatrix, -1)))); 

% get euclidean distances 
euclideanDistancesMatrix = pdist(data_zscore'); % euclidean distances

% get clusters
distance_metrics = euclideanDistancesMatrix;
hierarchical_cluster_tree = linkage(distance_metrics, 'ward');


%% Plot results

% Figure lay-out
dendrogram_height = 0.85;
correlationMatrixPlot_height = 0.7;
correlationMatrixPlot_width = 0.5 / (num_variables + 1);
overall_fig_size_x = 7;
overall_fig_size_y = 7;
figure('position',[10 10 1000 500]);

% Dendrogram
subplot('position',[0 dendrogram_height 1 1-dendrogram_height]);

colour_threshold = 'default';
[handles_to_lines, ~, variable_order] = dendrogram(hierarchical_cluster_tree, 0, 'colorthreshold', colour_threshold);

xticklabels = variable_names(variable_order);
set(gca, 'ytick', [], 'xticklabel', xticklabels, 'TickLength', [0,0], 'XTickLabelRotation',90);
set(handles_to_lines, 'LineWidth', 3);

% Correlation matrix
subplot('position',[correlationMatrixPlot_width 0 1-2*correlationMatrixPlot_width correlationMatrixPlot_height-0.01]);

% Get correlations
correlationMatrix_clusteredForPlotting = correlationMatrix;
% Order by clustering
correlationMatrix_clusteredForPlotting = correlationMatrix_clusteredForPlotting(variable_order, variable_order);
% Set diagonal to infinity for nicer plot
correlationMatrix_clusteredForPlotting(eye(length(correlationMatrix_clusteredForPlotting))>0) = Inf; 

% Plot
colormap(nmap);
imagesc(correlationMatrix_clusteredForPlotting,[(correlationMatrix_maxValue + 0.1)*(-1), (correlationMatrix_maxValue + 0.1)]);

% Settings
axis off;
daspect('auto');

set(gcf,...
    'Units', 'Inches', ...
    'Position', [0, 0, overall_fig_size_x, overall_fig_size_y], ...
    'PaperPositionMode', 'auto');

colorbar('Location','southoutside')

saveas(gcf, [dataFolder,'/figures/Dendogram.fig'])
exportgraphics(gcf, [dataFolder,'/figures/Dendrogram.pdf'])

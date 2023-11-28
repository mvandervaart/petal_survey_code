%% Code to analyse parental survey data as part of the Petal trial
% Author: Annalisa Hauck
% Code created 21-02-2023
% Adapted by: Marianne van der Vaart (July 2023, November 2023)

% Analyse survey data collected as part of the Petal trial. Produces
% figures 1, 2A, 2B and 3. 

% Petal trial protocol: Cobo MM, Moultrie F, Hauck AGV, et al Multicentre, randomised controlled trial to investigate 
% the effects of parental touch on relieving acute procedural pain in neonates (Petal) BMJ Open 2022;12:e061841. 
% doi: 10.1136/bmjopen-2022-061841

%% 0) Set Colours and paths

nmap = []; 
nmap(1,:) = [0.0157 0.1176 0.2588];
nmap(2,:) = [0.0000 0.3843 0.6078];
nmap(3,:) = [0.0000 0.5765 0.6980];
nmap(4,:) = [0.1647 0.8235 0.7882];
nmap(5,:) = [0.5882 0.580 0.623];

dataFolder = './data';
mkdir([dataFolder,'/figures'])

%% 1) Q3: Importance of different factors when deciding to take part in the Petal trial (bar chart)

% Load counts & number of responses
load([dataFolder,'/Q3_counts.mat'],'counts','numResponses')

% Labels
row1 = {'Contributing' 'Potential benefits' 'Potential benefits' 'Knowing that your' 'Concern that your'};
row2 = {'to science' 'to your baby'  'for future babies' 'baby would be' 'baby might be in pain'};
row3 = {'' '' '' 'monitored closely' 'from the blood test'};
labelArray = [row1; row2; row3]; 

% Rearrange counts by frequency
newOrder = [3, 1, 4, 2, 5];
counts_reordered = counts(newOrder,:) ./ numResponses * 100;
labelArray_reordered = labelArray(:,newOrder);

f = figure;  
f.Position = [10 10 900 600]; 
b = bar(counts_reordered,'stacked','FaceColor','flat',"FaceAlpha",0.8);

% Set colours
for iBar = 1:5
    b(iBar).CData = nmap(iBar,:);
    b(iBar).BarWidth = 0.4; 
end

% Set legend
legend('Very important','Important','Neutral','Not very important','Not considered','Location','bestoutside') 
legend(b([5 4 3 2 1]),'box','off')

% Lay-out
tickLabels = strtrim(sprintf('%s\\newline%s\\newline%s\n', labelArray_reordered{:}));
ax = gca(); 
ax.XTick = 1:5; 
ax.XTickLabel = tickLabels; 
ax.TickDir = "out";
xtickangle(40)
ax.YLim = [0 100];
ax.FontSize = 13; 
[t]= title("Reasons for taking part in the study");
t.FontSize = 15;
ylabel("Percentage of responses")
box('off')

set(f, 'Position', [419         449        1327         467])

% Save
saveas(f, [dataFolder,'/figures/Q3.fig'])
exportgraphics(f, [dataFolder,'/figures/Q3.pdf'])

%% 2a) Q4: Feelings both arms (bar chart)

% Load data
load([dataFolder,'/Q4_counts_all.mat'],'Q4sum','Q4numResponses','tickLabels')

% Set figure
f = figure; 
f.Position = [10 10 900 600]; 

% Reorder bar plot based on frequency (convert to %)
[sortedY, sortOrder] = sort(Q4sum / Q4numResponses * 100, 'descend');
sortedX = tickLabels(sortOrder);

% Plot the bar chart from largest to smallest.
b = bar(sortedY, "FaceAlpha",1);
b.BarWidth = 0.4;
b.FaceColor = nmap(1,:);

% Lay-out
ax = gca(); 
ax.XTick = 1:10; 
ax.XTickLabel = sortedX; 
t = title(["Being actively involved in caring for my child at the time of their blood test made me feel… (n = ", num2str(Q4numResponses)]);
ylabel("Percentage of responses")
set(gca,'fontsize',13)
t.FontSize = 15;
ax.TickDir = "out";
ax.YLim = [0, 80];
set(gca,'box','off')

saveas(f, [dataFolder,'/figures/Q4_all.fig'])
exportgraphics(f, [dataFolder,'/figures/Q4_all.pdf'])


%% 2b) Feelings by arm (bar chart)

load([dataFolder,'/Q4_counts_byarm.mat'],'Q4sum_post','Q4sum_pre','Q4numResponsesPost','Q4numResponsesPre','tickLabels')

f = figure; hold on
f.Position = [10 10 900 600]; 

% Combine in one table (convert to %) and reorder by frequency
x = table(Q4sum_pre'./Q4numResponsesPre * 100, Q4sum_post'./Q4numResponsesPost * 100, tickLabels);
x_reordered = sortrows(x,1,'descend');

% Create bar chart
b = cell(2,1);
for iCondition = 1:2
    b{iCondition} = bar((1:10) + 0.3 * (iCondition-1), x_reordered{:,iCondition}, "FaceAlpha",1);
    b{iCondition}.BarWidth = 0.2;
    b{iCondition}.FaceColor = nmap(iCondition * 2,:);
end
hold off

% Figure lay-out
ax = gca(); 
ax.FontSize = 13; 
ax.TickDir = "out";
ax.XTick = (1:10) + 0.15; 
tickLabels_reordered = x_reordered{:,3};
ax.XTickLabel = tickLabels_reordered; 
ax.YLim = [0, 80];

t = title("Being actively involved in caring for my child at the time of their blood test made me feel...");
ylabel("Percentage of responses")
t.FontSize = 15;

% Plot significance 
hold on
plot(9.15,25,'k*') 
plot([8.9 9.4],[23 23],'k')
hold off

legend (['Stroked before (n = ', num2str(Q4numResponsesPre),')'], ['Stroked after (n = ', num2str(Q4numResponsesPost),')'],"Fisher's exact test, p < 0.05",...
    'box','off')

saveas(f, [dataFolder,'/figures/Q4_byarm.fig'])
exportgraphics(f, [dataFolder,'/figures/Q4_byarm.pdf'])


%% 2c) Feelings pre-stroking vs post-stroking (Fisher's exact test)
load([dataFolder,'/Q4_counts_byarm.mat'],'Q4sum_post','Q4sum_pre','Q4numResponsesPost','Q4numResponsesPre','tickLabels')
h = NaN(1,10); p = h; 
for i = 1:10
    x = table([Q4sum_pre(i);Q4sum_post(i)],[Q4numResponsesPre - Q4sum_pre(i); Q4numResponsesPost - Q4sum_post(i)], ...
        'VariableNames',{'Feelings present','Feeling not present'},'RowNames',{'Pre','Post'});
    [h(i), p(i)] = fishertest(x);
end

fishertest_arm = table(tickLabels, h', round(p,2)');
fishertest_arm.Properties.VariableNames = {'Descriptor','Fisher_H0_rejected','Fisher_p-val'}
writetable(fishertest_arm, [dataFolder,'/fishertest_arm.csv'])







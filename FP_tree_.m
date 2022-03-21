clear all
close all
clc

load encoded_mat
load abbrev
load decoder



%% Example for decoding

[rows,cols] = find(encoded_mat(1,:)>0);

decoder(cols,:)



%%

addpath('FPGrowth')


T={};

for i=1:size(encoded_mat,1)
    [rows,cols] = find(encoded_mat(i,:)>0);
    T{i,1}=cols;
end    


%% Mine 

MST=0.2;    % Minimum Suppport Threshold
MCT=0.01;    % Minimum Confidence Threshold
out=FPGrowth(T,MST,MCT);

% DGY: MST=0.18-al találunk 2 db szabályt.

%% Plot the tree 
%the parameters of the plot has to be set in PlotTree.m 
% the font size is proportional to the support

figure(101)
Tree=out.Node;
PlotTree(Tree);

figure(102)
Tree2=out.Node;
for i = 2:size(Tree2,2)
    Tree2(i).Name = char(abbrev{Tree2(i).Name});
end
PlotTree2(Tree2);


%%

FinalRules=out.FinalRules;

if ~isempty(FinalRules)
    
    for i = 1:size(FinalRules)
        for j = 1:2
            FinalRules{i,j} = join(string(abbrev{FinalRules{i,j}})',' ; ');
        end
    end
    
    
    disp('Final Rules:');
    disp(' ');
    DisplayRules_str(FinalRules);
    disp(' ');
    
    
    for i = 1:length(FinalRules)
        a{i,1} = "=>";
    end
    
    FinalRules = [FinalRules(:,1) FinalRules(:,2:end)];
    
    Climate_rules = cell2table(FinalRules,'VariableNames',{'Rule1' 'follow' 'Rule2' 'supp' 'conf' 'lift'})
    writetable(Climate_rules,'Climate_rules')
    
end




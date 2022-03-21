clear all
close all
clc

T = readtable('city_emissions_gases.xlsx');

gasmat = zeros(size(T,1),7);

for i=1:size(T,1)
    newStr = erase(T{i,1}{1}," ");
    gases = split(newStr,',');
    
    for g = 1:size(gases,1)
        if strcmp(gases{g,1},'CH4')
            gasmat(i,1) = 1;
        elseif strcmp(gases{g,1},'CO2')
            gasmat(i,2) = 1;
        elseif strcmp(gases{g,1},'N20')
            gasmat(i,3) = 1;
        elseif strcmp(gases{g,1},'NF3')
            gasmat(i,4) = 1;
        elseif strcmp(gases{g,1},'HFCs')
            gasmat(i,5) = 1;
        elseif strcmp(gases{g,1},'PFCs')
            gasmat(i,6) = 1;
        elseif strcmp(gases{g,1},'SF6')
            gasmat(i,7) = 1;
        else
            if ~isempty(gases{g,1})
                gases{g,1}
            end
        end
    end
end


varNames = {'CH4','CO2','N20','NF3','HFCs','PFCs','SF6'};

t = table(gasmat(:,1),gasmat(:,2),gasmat(:,3),gasmat(:,4),gasmat(:,5),gasmat(:,6),gasmat(:,7),'VariableNames',varNames);
writetable(t,'gas_columns.xlsx')

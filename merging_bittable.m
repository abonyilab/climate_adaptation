clear all
close all
clc

tic
addpath('Measures of Effect Size (MES) Toolbox')
df1 = readtable('CDP20210520\Master_DBv4.xlsx','Sheet','01_Climate_Hazards');

df2 = readtable('CDP20210520\Master_DBv4.xlsx','Sheet','02_Adaptation_Actions');


%%%%%%%%%%%%%%%%%% Ensuring matching category names %%%%%%%%%%%%%%%%%%

hazards = [df1{:,5};df2{:,4}];

hazard_types = unique(hazards); % we have a Biological hazard with double space

ind = find(strcmp(df1{:,5},'Biological hazards  > Air-borne disease')) % nem itt
ind = find(strcmp(df2{:,4},'Biological hazards  > Air-borne disease'))
df2{ind,4} = {'Biological hazards > Air-borne disease'}; % removing the extra space


df3 = readtable('CDP20210520\Master_DBv4.xlsx','Sheet','03_Emission_Reduction_Actions');


KG_classes = xlsread('CDP20210520\KG_classes_new.xlsx');%,'Sheet','04_Emission_Reduction_Targets')
[KG_legend, KG_legend_labels] = xlsread('CDP20210520\KG_classes_legends.xlsx');

%% 01 Analysis of climate hazards

%%%%%%%%%%%%%%%%%% adding no entry hazard %%%%%%%%%%%%%%%%%%

for i = 1:size(df1{:,5},1)
    if isempty(df1{i,5}{1,1})
        df1{i,5}{1,1} = 'NO_HAZARD_ENTRY';
    end
end

%%%%%%%%%%%%%%%%%% occurrence of different hazards %%%%%%%%%%%%%%%%%%

[hazard_types,ia,ic] = unique(df1{:,5});

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
hazard_counts = hazard_types(ind);


for i =1:length(a_counts)
    hazard_counts(i,2) = {a_counts(i)};
end


figure(1)
bar(cell2mat(hazard_counts(1:15,2)))
set(gca,'xticklabel',hazard_counts(1:15,1))
xtickangle(45)
ylabel('Number of entries [-]')
% saveas(gcf,'hazard_types.png')


%% 02 Modification

%%%%%%%%%%%%%%%%%% adding no entry hazard %%%%%%%%%%%%%%%%%%

for i = 1:size(df2{:,4},1)
    if isempty(df2{i,4}{1,1})
        df2{i,4}{1,1} = 'NO_HAZARD_ENTRY';
    end
end

%%%%%%%%%%%%%%%%%% adding no entry hazard %%%%%%%%%%%%%%%%%%

for i = 1:size(df2{:,5},1)
    if isempty(df2{i,5}{1,1})
        df2{i,5}{1,1} = 'NO_ACTION_ENTRY';
    end
end


%% 01 and 02 Joining "Climate hazards" and the associated "adaptation actions"



%%%%%%%%%%%%%%%%%% NO_ACTION_FOR_HAZARD is added if hazard is not actioned %%%%%%%%%%%%%%%%%%
% The joining of tables is based on the account number of the city and the
% hazard records of the city. In most of the cases, the hazard is already
% actioned, if not, we add the unaction hazard to the df2 dataset. 

for i = 1:size(df1)

    ind = find(df2{:,1} == df1{i,1});
    dft = df2(ind,:);
    dft = dft(strcmp(df1{i,5},dft{:,4}),:);
    
    if isempty(dft)        
        acc_num = df1{i,1};
        pop = df2(df2{:,1}==acc_num,10);
        addrow = {df1{i,1}, df1{i,2},df1{i,3},df1{i,5},'NO_ACTION_FOR_HAZARD','','','',0,pop{1,1}}; % City nevet ki kell kerestetni, hozzá population
        df2 = [df2;addrow];
    end
    
end

%% 02 Actions

%%%%%%%%%%%%%%%%%% occurrence of different actions %%%%%%%%%%%%%%%%%%


adapt_actions = [df2{:,5}];
[adapt_action_types,ia,ic] = unique(adapt_actions);

% TASK: 320 action type, but many of them can be merged based on expert
% knowledge.

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
action_counts = adapt_action_types(ind);


for i =1:length(a_counts)
    action_counts(i,2) = {a_counts(i)};
end

%%%%%%%%%%%%%%%%%% Creating a POOL for rare actions %%%%%%%%%%%%%%%%%%

ind = find(cell2mat(action_counts(:,2))<10);

for i = 1:length(ind)
%     df2(:,5)  action_counts(ind(i),1)
%     ind2 = find(strcmp(df2{:,5},action_counts(ind(1),1)))
    df2{strcmp(df2{:,5},action_counts(ind(i),1)),5}={'Other'};
end

df2{contains(df2{:,5},'Other'),5} = {'Other'};
%%%%%%%%%%%%%%%%%% RECALCULATING occurrence of different actions %%%%%%%%%%%%%%%%%%


adapt_actions = [df2{:,5}];
[adapt_action_types,ia,ic] = unique(adapt_actions);

% TASK: 320 action type, but many of them can be merged based on expert
% knowledge.

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
action_counts = adapt_action_types(ind);


for i =1:length(a_counts)
    action_counts(i,2) = {a_counts(i)};
end




%% 02 Means of implementation

%%%%%%%%%%%%%%%%%% adaptation means of implementation %%%%%%%%%%%%%%%%%%

for i = 1:size(df2{:,6},1)
    if isempty(df2{i,6}{1,1})
        df2{i,6}{1,1} = 'NO_IMPL_ENTRY';
    end
end

means_of_impl = {};
for i = 1:size(df2,1)
    impls = split(df2{i,6},'; ');
    if sum(contains(impls,'Other'))>0
        impls{contains(impls,'Other')} = 'Other';
    end
    means_of_impl = [means_of_impl; impls];
end

[adapt_impl_types,ia,ic] = unique(means_of_impl);

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
adapt_impl_counts = adapt_impl_types(ind);


for i =1:length(a_counts)
    adapt_impl_counts(i,2) = {a_counts(i)};
end

figure(3)
bar(cell2mat(adapt_impl_counts(:,2)))
set(gca,'xticklabel',adapt_impl_counts(:,1))
xtickangle(45)
ylabel('Number of entries [-]')
% saveas(gcf,'adapt_impl_actions.png')


%%%%%%%%%%%%%%%%%% co-benefit %%%%%%%%%%%%%%%%%%

for i = 1:size(df2{:,7},1)
    if isempty(df2{i,7}{1,1})
        df2{i,7}{1,1} = 'NO_COBENEF_ENTRY';
    end
end

adapt_cobenef = {};
for i = 1:size(df2,1)
    cobenfs = split(df2{i,7},'; ');
%     if sum(contains(cobenfs,'Other'))>0
%         cobenfs{contains(cobenfs,'Other')} = 'Other';
%     end
    adapt_cobenef = [adapt_cobenef; cobenfs];
end

[adapt_cobenef_types,ia,ic] = unique(adapt_cobenef);

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
adapt_cobenef_counts = adapt_cobenef_types(ind);


for i =1:length(a_counts)
    adapt_cobenef_counts(i,2) = {a_counts(i)};
end

figure(13)
bar(cell2mat(adapt_cobenef_counts(:,2)))
set(gca,'xticklabel',adapt_cobenef_counts(:,1))
xtickangle(45)
ylabel('Number of entries [-]')
% saveas(gcf,'adapt_impl_actions.png')



%%%%%%%%%%%%%%%%%% population %%%%%%%%%%%%%%%%%%

population = table2array(df2(:,10));

% <10.000, <100.000, <1.000.000, <5.000.000, 10.000.000
% max population ----> we will need to fix the extreme high values
population(population<=50000) = 50000;
population(population>50000 & population<=200000) = 200000;
population(population>200000 & population<=500000) = 500000;
population(population>500000 & population<=1500000) = 1500000;
population(population>1500000) = 2500000;

df2(:,10) = table(population);


for i = 1:size(df2{:,10},1)
    
    switch df2{i,10}
        case 50000
            df2{i,11} = "Towns";
        case 200000
            df2{i,11} ="Small Urban Area";
        case 500000
            df2{i,11} = "Medium Urban Area";
        case 1500000
            df2{i,11} = "Metropolitan Area";
        case 2500000
            df2{i,11} = "Large Metropolitan Area";
        otherwise
            df2{i,11} = "NO POPULATION ENTRY";
    end
    
end

% for i = 1:size(df2{:,11},1)
%     if strcmp(df2{i,11}{1,1},'NaN')
%         df2{i,11}{1,1}= 'NO_POP_ENTRY';
%     end
% end

[population_types,ia,ic] = unique(df2{:,11});


%% 02 Column 12: KG_class

accnum = unique(df1(:,1));

for i = 1:size(df2,1)
    acc = table2array(df2(i,1));
    KG_class = KG_classes(KG_classes(:,5)==acc,7);
    if ~isempty(KG_class)
        df2(i,12) = {num2str(KG_class)};
    else
        df2(i,12) = {'NO_KG_CLASS'};
    end
end

[KG_class_types,ia,ic] = unique(df2{:,12});

%%
encPop =  [];
encKG = [];
for i = 1:size(accnum,1)
    city_df = df2(df2{:,1}==accnum{i,1},:);
   
    encPop = [encPop; onehotencode(categorical(city_df{:,11}(1)),2,"ClassNames",population_types)];
    encKG = [encKG; onehotencode(categorical(city_df{:,12}(1)),2,"ClassNames",KG_class_types)];
end

%% Clearing

% So now that everything is together in df2, we drop out certain rows and
% determine the categories again after that.

% If we have no hazard entry, we drop that entire row from df2.
df2 = df2(~strcmp(df2{:,4}, 'NO_HAZARD_ENTRY'),:);


% If we have no hazard entry, we drop that entire row from df2.
df2 = df2(~strcmp(df2{:,5}, 'NO_ACTION_FOR_HAZARD'),:);
df2 = df2(~strcmp(df2{:,5}, 'NO_ACTION_ENTRY'),:);

[hazard_types,ia,ic] = unique(df2{:,4});
[adapt_action_types,ia,ic] = unique(df2{:,5});

%%%%%%%%%%%%%%%%%%%5 

adapt_impl_types = adapt_impl_types(~strcmp(adapt_impl_types,'NO_IMPL_ENTRY'));

adapt_cobenef_types = adapt_cobenef_types(~strcmp(adapt_cobenef_types,'NO_COBENEF_ENTRY'));

%% 

%Implementation & Cobenefit
impl_mat_size = length(hazard_types)*length(adapt_action_types)*length(adapt_impl_types);
cobenef_mat_size = length(hazard_types)*length(adapt_action_types)*length(adapt_cobenef_types);

city_Impls = zeros(size(accnum,1),impl_mat_size);
city_Cobenef = zeros(size(accnum,1),cobenef_mat_size);
encoded_mat = [];
for i = 1:size(accnum,1)
    city_df = df2(df2{:,1}==accnum{i,1},:);
   hazard_cats = categorical(city_df{:,4});

   if ~isempty(hazard_cats)
       encHazards = onehotencode(hazard_cats,2,"ClassNames",hazard_types);
   else
       encHazards = zeros(1,length(hazard_types));
   end
    
%     city_encHazards = [city_encImpls; sum(encHazards,1)];

    city_Actions = [];
    for h = 1:size(hazard_types,1)
        hazard = hazard_types{h};
        
        hazard_df = city_df(strcmp(city_df{:,4},hazard),:);
        action_cats = categorical(hazard_df{:,5});
        
        if ~isempty(action_cats)
            encActions = onehotencode(action_cats,2,"ClassNames",adapt_action_types);
        else
            encActions = zeros(1,length(adapt_action_types));
        end
        
        
        city_Actions = [city_Actions sum(encActions,1)];
        
        for a = 1:size(hazard_df)
            hazard_ID = find(strcmp(hazard_df{a,4},hazard_types));
            action_ID = find(strcmp(hazard_df{a,5},adapt_action_types));
            
            impls = split(hazard_df{a,6},'; ');
            if sum(contains(impls,'Other'))>0
                impls{contains(impls,'Other')} = 'Other';
            end
            
            impls = impls(~strcmp(impls,'NO_IMPL_ENTRY')); % Removing of NO_IMPL_ENTRY 
            impl_cats = categorical(impls);
            if ~isempty(impl_cats)
                encImpls = onehotencode(impl_cats,2,"ClassNames",adapt_impl_types);
            else
                encImpls = zeros(1,length(adapt_impl_types));
            end
            
            
            st_ind = (hazard_ID-1)*length(adapt_action_types)*length(adapt_impl_types)+(action_ID-1)*length(adapt_impl_types)+1;
            
            city_Impls(i,st_ind:st_ind+length(adapt_impl_types)-1) = sum(encImpls,1);
            
            %%%%%%%%%%%%%%%%%%%%%
            
            cobenfs = split(hazard_df{a,7},'; ');

            cobenfs = cobenfs(~strcmp(cobenfs,'NO_COBENEF_ENTRY')); % Removing of NO_COBENEF_ENTRY 
            cobenef_cats = categorical(cobenfs);
            
            if ~isempty(cobenef_cats)
                encCobenef = onehotencode(cobenef_cats,2,"ClassNames",adapt_cobenef_types);
            else
                encCobenef = zeros(1,length(adapt_cobenef_types));
            end
            
            st_ind = (hazard_ID-1)*length(adapt_action_types)*length(adapt_cobenef_types)+(action_ID-1)*length(adapt_cobenef_types)+1;
            
            city_Cobenef(i,st_ind:st_ind+length(adapt_cobenef_types)-1) = sum(encCobenef,1);
            
             

        end
    end
   
    encoded_mat = [encoded_mat; [sum(encHazards,1) city_Actions]];


end

% encoded_mat = [encKG, encPop, encoded_mat, city_Impls, city_Cobenef];

encoded_mat = [encoded_mat, city_Impls, city_Cobenef];

%% 03 Mitigation


for i = 1:size(df3{:,4},1)
    if isempty(df3{i,4}{1,1})
        df3{i,4}{1,1} = 'NO_MITIG_ACTION';
    end
end


[mitig_action_types,ia,ic] = unique(df3{:,4});

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
mitig_action_counts = mitig_action_types(ind);


for i =1:length(a_counts)
    mitig_action_counts(i,2) = {a_counts(i)};
end

figure(23)
bar(cell2mat(mitig_action_counts(:,2)))
set(gca,'xticklabel',mitig_action_counts(:,1))
xtickangle(45)
ylabel('Number of entries [-]')



for i = 1:size(df3{:,5},1)
    if isempty(df3{i,5}{1,1})
        df3{i,5}{1,1} = 'NO_MITIG_IMPL_ENTRY';
    end
end


[mitig_impl_types,ia,ic] = unique(df3{:,5});

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
mitig_impl_counts = mitig_impl_types(ind);


for i =1:length(a_counts)
    mitig_impl_counts(i,2) = {a_counts(i)};
end

figure(24)
bar(cell2mat(mitig_impl_counts(:,2)))
set(gca,'xticklabel',mitig_impl_counts(:,1))
xtickangle(45)
ylabel('Number of entries [-]')


%%%%%%%%%%%%%%%%%% co-benefit %%%%%%%%%%%%%%%%%%

for i = 1:size(df3{:,10},1)
    if isempty(df3{i,10}{1,1})
        df3{i,10}{1,1} = 'NO_COBENEF_ENTRY';
    end
end

mitig_cobenef = {};
for i = 1:size(df3,1)
    cobenfs = split(df3{i,10},'; ');
%     if sum(contains(cobenfs,'Other'))>0
%         cobenfs{contains(cobenfs,'Other')} = 'Other';
%     end
    mitig_cobenef = [mitig_cobenef; cobenfs];
end

[mitig_cobenef_types,ia,ic] = unique(mitig_cobenef);

a_counts = accumarray(ic,1);

[a_counts, ind] = sort(a_counts,'descend');
mitig_cobenef_counts = mitig_cobenef_types(ind);


for i =1:length(a_counts)
    mitig_cobenef_counts(i,2) = {a_counts(i)};
end

figure(24)
bar(cell2mat(mitig_cobenef_counts(:,2)))
set(gca,'xticklabel',mitig_cobenef_counts(:,1))
xtickangle(45)
ylabel('Number of entries [-]')

%% Mitigation, dropping missing entries


% If we have no hazard entry, we drop that entire row from df2.
df3 = df3(~strcmp(df3{:,4}, 'NO_MITIG_ACTION'),:);
[mitig_action_types,ia,ic] = unique(df3{:,4});

mitig_impl_types = mitig_impl_types(~strcmp(mitig_impl_types,'NO_MITIG_IMPL_ENTRY'));

mitig_cobenef_types = mitig_cobenef_types(~strcmp(mitig_cobenef_types,'NO_COBENEF_ENTRY'));


%% Mitigation encoding


encoded_mitigation = [];
city_Mitig_cobenef = zeros(size(accnum,1),length(mitig_action_types)*length(mitig_cobenef_types));

for i = 1:size(accnum,1)
    city_df = df3(df3{:,1}==accnum{i,1},:);
    
    mitig_cats = categorical(city_df{:,4});
    if ~isempty(mitig_cats)
        encMitigs = onehotencode(mitig_cats,2,"ClassNames",mitig_action_types);
    else
        encMitigs = zeros(1,length(mitig_action_types));
    end
    
    
    city_Mitig_impl = [];
    for m = 1:size(mitig_action_types,1)
        mitig = mitig_action_types{m};
        
        mitig_df = city_df(strcmp(city_df{:,4},mitig),:);
                 
        mitig_impl = mitig_df{:,5};
        mitig_impl = mitig_impl(~strcmp(mitig_impl,'NO_MITIG_IMPL_ENTRY')); % Removing of NO_MITIG_IMPL_ENTRY 
        mitig_impl_cats = categorical(mitig_impl);
        
        if ~isempty(mitig_impl_cats)
            encMitigImpl = onehotencode(mitig_impl_cats,2,"ClassNames",mitig_impl_types);
        else
            encMitigImpl = zeros(1,length(mitig_impl_types));
        end
        
        
        city_Mitig_impl = [city_Mitig_impl sum(encMitigImpl,1)];
        
       
       
        
        
        for a = 1:size(mitig_df)
            mitig_act_ID = find(strcmp(mitig_df{a,4},mitig_action_types));
            mitig_cobenefs = split(mitig_df{a,10},'; ');
            mitig_cobenefs = mitig_cobenefs(~strcmp(mitig_cobenefs,'NO_COBENEF_ENTRY')); % Removing of NO_COBENEF_ENTRY 
            mitig_cobenef_cats = categorical(mitig_cobenefs);
            
            if ~isempty(mitig_cobenef_cats)
                encMitigCobenef = onehotencode(mitig_cobenef_cats,2,"ClassNames",mitig_cobenef_types);
            else
                encMitigCobenef = zeros(1,length(mitig_cobenef_types));
            end
           
            
            st_ind = (mitig_act_ID-1)*length(mitig_cobenef_types)+1;
            
            city_Mitig_cobenef(i,st_ind:st_ind+length(mitig_cobenef_types)-1) = sum(encMitigCobenef,1);
            
            
        end
        
        
    end
   
    encoded_mitigation = [encoded_mitigation; [sum(encMitigs,1) city_Mitig_impl]];


end

encoded_mitigation = [encoded_mitigation city_Mitig_cobenef];
encoded_mat = [encoded_mat encoded_mitigation];

%%

% st_population = length(KG_class_types)+1;
st_hazard = 1;
st_action = length(hazard_types)+1;
st_impl = length(hazard_types) + length(hazard_types)*length(adapt_action_types)+1;
st_cobenef = length(hazard_types) + length(hazard_types)*length(adapt_action_types)+length(hazard_types)*length(adapt_action_types)*length(adapt_impl_types)+1;
st_mitigact = st_cobenef + length(hazard_types)*length(adapt_action_types)*length(adapt_cobenef_types);
st_mitigimpl = st_mitigact + length(mitig_action_types);
st_mitigcobenef = st_mitigimpl + length(mitig_action_types)*length(mitig_impl_types);

% decoder = KG_class_types;
% 
% decoder(length(KG_class_types)+1:length(KG_class_types)+length(population_types),1) = population_types;

% decoder(st_hazard:st_hazard+length(hazard_types)-1,1) = hazard_types;
decoder = hazard_types;

for h = 1:length(hazard_types)
    clear tmp
    tmp(:,2) = adapt_action_types;
    tmp(:,1) = hazard_types(h);
    decoder(end+1:end+length(tmp),1:2) = tmp;
end


for h = 1:length(hazard_types)
    for a = 1:length(adapt_action_types)
        clear tmp
        tmp(:,3) = adapt_impl_types;
        tmp(:,2) = adapt_action_types(a);
        tmp(:,1) = hazard_types(h);
        decoder(end+1:end+length(tmp),1:3) = tmp;
    end
end

for h = 1:length(hazard_types)
    for c = 1:length(adapt_action_types)
        clear tmp
        tmp(:,3) = adapt_cobenef_types;
        tmp(:,2) = adapt_action_types(c);
        tmp(:,1) = hazard_types(h);
        decoder(end+1:end+length(tmp),1:3) = tmp;
    end
end
decoder(end+1:end+length(mitig_action_types),1) = mitig_action_types;

for m = 1:length(mitig_action_types)
    clear tmp
    tmp(:,2) = mitig_impl_types;
    tmp(:,1) = mitig_action_types(m);
    decoder(end+1:end+length(tmp),1:2) = tmp;
end

for m = 1:length(mitig_action_types)
    clear tmp
    tmp(:,2) = mitig_cobenef_types;
    tmp(:,1) = mitig_action_types(m);
    decoder(end+1:end+length(tmp),1:2) = tmp;
end


%%
abbrev = {};
% 
% for i = 1:length(KG_class_types)
%     abbrev(i,1) = {'k_{'+string(i)+'}'};
% end
% for i = 1:length(population_types)
%     abbrev(length(KG_class_types)+i,1) = {'p_{'+string(i)+'}'};
% end
for i = 1:length(hazard_types)
    abbrev(i,1) = {'h_{'+string(i)+'}'};
end

for h = 1:length(hazard_types)
    for a = 1:length(adapt_action_types)
        abbrev(end+1,1) = {'h_{' + string(h) + '}a_{' + string(a)+'}'};
    end
end

for h = 1:length(hazard_types)
    for a = 1:length(adapt_action_types)
        for i=1:length(adapt_impl_types)
            abbrev(end+1,1) = {'h_{' + string(h) + '}a_{' + string(a) + '}i_{' + string(i)+'}'};
        end
    end
end

for h = 1:length(hazard_types)
    for a = 1:length(adapt_action_types)
        for ca=1:length(adapt_cobenef_types)
            abbrev(end+1,1) = {'h_{' + string(h) + '}a_{' + string(a) + '}ca_{' + string(ca)+'}'};
        end
    end
end


for ma = 1:length(mitig_action_types)
    abbrev(end+1,1) = {'ma_{'+string(ma)+'}'};
end

for ma = 1:length(mitig_action_types)
    for mi = 1:length(mitig_impl_types)
        abbrev(end+1,1) = {'ma_{' + string(ma) + '}mi_{' + string(mi)+'}'};
    end
end


for ma = 1:length(mitig_action_types)
    for mc = 1:length(mitig_cobenef_types)
        abbrev(end+1,1) = {'ma_{' + string(ma) + '}mc_{' + string(mc)+'}'};
    end
end

encoded_mat = encoded_mat>0;

save encoded_mat encoded_mat
save abbrev abbrev
save decoder decoder

delete Code_Table.xlsx


T = table([1:length(KG_class_types)]',KG_class_types);
writetable(T,'Code_Table.xlsx','Sheet','KG_class_types')
T = table([1:length(population_types)]',population_types);
writetable(T,'Code_Table.xlsx','Sheet','population_types')
T = table([1:length(hazard_types)]',hazard_types);
writetable(T,'Code_Table.xlsx','Sheet','hazard_types')
T = table([1:length(adapt_action_types)]',adapt_action_types);
writetable(T,'Code_Table.xlsx','Sheet','adapt_action_types')
T = table([1:length(adapt_impl_types)]',adapt_impl_types);
writetable(T,'Code_Table.xlsx','Sheet','adapt_impl_types')
T = table([1:length(adapt_cobenef_types)]',adapt_cobenef_types);
writetable(T,'Code_Table.xlsx','Sheet','adapt_cobenef_types')
T = table([1:length(mitig_action_types)]',mitig_action_types);
writetable(T,'Code_Table.xlsx','Sheet','mitig_action_types')
T = table([1:length(mitig_impl_types)]',mitig_impl_types);
writetable(T,'Code_Table.xlsx','Sheet','mitig_impl_types')
T = table([1:length(mitig_cobenef_types)]',mitig_cobenef_types);
writetable(T,'Code_Table.xlsx','Sheet','mitig_cobenef_types')


%%
encHazards_mat = encoded_mat(:,1:length(encHazards));
cont_table = zeros(size(encHazards_mat,2),size(encKG,2));
for c = 1:size(encKG,2)
    for r=1:size(encHazards_mat,2)
        cross_table = zeros(2,2);
        cross_table(1,1)=sum(encKG(:,c)>0 & encHazards_mat(:,r)>0);
        cross_table(2,1)=sum(encKG(:,c)>0 & encHazards_mat(:,r)==0);
        cross_table(1,2)=sum(encKG(:,c)==0 & encHazards_mat(:,r)>0);
        cross_table(2,2)=sum(encKG(:,c)==0 & encHazards_mat(:,r)==0);
        stats=mestab(cross_table);
        cont_table(r,c) = stats.phi;
    end
end

kgcl = cellfun(@str2num, KG_class_types)
KG_class_labels = {}
for i = 1:length(kgcl)
KG_class_labels{i} = KG_legend_labels{1 + find(KG_legend == kgcl(i)), 2};
end

figure(136)
h = heatmap(cont_table, 'XDisplayLabels', char(KG_class_labels'), 'YData',hazard_types)
h.CellLabelFormat = '%.2f'

cont_table = zeros(size(encHazards_mat,2),size(encPop,2));
for c = 1:size(encPop,2)
    for r=1:size(encHazards_mat,2)
        cross_table = zeros(2,2);
        cross_table(1,1)=sum(encPop(:,c)>0 & encHazards_mat(:,r)>0);
        cross_table(2,1)=sum(encPop(:,c)>0 & encHazards_mat(:,r)==0);
        cross_table(1,2)=sum(encPop(:,c)==0 & encHazards_mat(:,r)>0);
        cross_table(2,2)=sum(encPop(:,c)==0 & encHazards_mat(:,r)==0);
        stats=mestab(cross_table);
        cont_table(r,c) = stats.phi;
    end
end

figure(137)
h = heatmap(cont_table, 'XData', population_types, 'YData',hazard_types)
h.CellLabelFormat = '%.2f'

%Amount of city types in the database
%length(encPop(encPop(:, 3) == 1))

%length(KG_classes(KG_classes(:, 7) == 11))
toc
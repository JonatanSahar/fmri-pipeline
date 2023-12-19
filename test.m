function test()
Biases = rand(18,3*5*2); % subjects, HRs*obstacle pos.*VFs
varNames = cell(3*5*2,1);
for i = 1 : 3*5*2
 v = strcat('V',num2str(i));
 varNames{i,1} = v;
end
% Create a table storing the respones
tbiases = array2table(Biases, 'VariableNames',varNames);
% Create a table reflecting the within subject factors
HRs = cell(3*5*2,1); % head roll conditions
VFs = cell(3*5*2,1); % Visual feedback conditions
OPs = cell(3*5*2,1); % Obstacle Positions
% Assiging the values to the parameters based on the data sorting
c1 = cell(1,1); c1{1} = 'Y'; c1 = repmat(c1,15,1); VFs(1: 15,1) = c1;
c1 = cell(1,1); c1{1} = 'N'; c1 = repmat(c1,15,1); VFs(16: end,1) = c1;
c1 = cell(1,1); c1{1} = 'HR0'; c1 = repmat(c1,10,1); HRs(1:3:end,1) = c1;
c1 = cell(1,1); c1{1} = 'HRL'; c1 = repmat(c1,10,1); HRs(2:3:end,1) = c1;
c1 = cell(1,1); c1{1} = 'HRR'; c1 = repmat(c1,10,1); HRs(3:3:end,1) = c1;
for i = 1 : 5
 o = strcat('O',num2str(i));
 c1 = cell(1,1); c1{1} = o; c1 = repmat(c1,3,1); 
 OPs((i-1)*3+1:i*3,1) = c1;
end
OPs(16:end,1) = OPs(1:15,1);
% Create the within table
factorNames = {'HRs','VisualFeedback', 'ObstaclePos'};
within = table(HRs, VFs, OPs, 'VariableNames', factorNames);
% fit the repeated measures model
rm = fitrm(tbiases,'V1-V30~1','WithinDesign',within);
[ranovatblb] = ranova(rm, 'WithinModel','HRs*VisualFeedback*ObstaclePos');
end

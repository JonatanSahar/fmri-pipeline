function res = scoringToMatrix(mask, data, locations)

if ndims(mask) == 3 
    res = zeros(size(mask));
else
    res = zeros(mask, mask, mask);
    % used to be 
%     res = zeros(dimensions, dimensions, dimensions);
% but I changd it since mask is either a 3d logical array
% but in old Ariel version it was just a number (like 128) 
end



for i = 1:size(data,1)
    % added this if statemnt since in old code Ariel's use parfor to
    % construct ansMat variable (called data here). since he used parfor he
    % had anohter coolumn in data (the first column) wit ha runnning count
    % of idx, in time, we moved away from using this so the order of dta is
    % correct here and we just give a single version. 
    if size(data,2) == 2
        res(locations(data(i,1),1),locations(data(i,1),2),locations(data(i,1),3)) = data(i,2);
    elseif size(data,2) == 1 
        res(locations(i,1),locations(i,2),locations(i,3)) = data(i);
end
%% for testing 
%{
res = zeros(dimensions, dimensions, dimensions);
for i = 1:size(locations,1)
    res(locations(data(i,1),1),locations(data(i,1),2),locations(data(i,1),3)) = data(i,2);
end
%}
%% 
end
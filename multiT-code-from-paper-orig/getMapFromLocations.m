function outmap = getMapFromLocations(locations,map)
% Given a map of the interesting places in the brain,
% and a 'template map' return newmap based on locations 
outmap = zeros(size(map));
for i = 1:size(locations,1)
    outmap(locations(i,1),locations(i,2),locations(i,3)) = 1;
end
end
% Given a map of the interesting places in the brain, returns a vector
% containing the x,y,z coordinates of the interesting voxels.
function res = getLocations(map)
numOfElemes = sum(sum(sum(map)));
res = zeros(numOfElemes, 3);
loc = 1;
for i = 1:size(map,1)
    for j = 1:size(map,2)
        for k = 1:size(map,3)
            if map(i,j,k)
                res(loc,:) = [i,j,k];
                loc = loc + 1;
            end
        end
    end
end

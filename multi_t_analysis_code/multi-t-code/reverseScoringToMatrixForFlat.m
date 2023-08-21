function ansMat = reverseScoringToMatrixForFlat(fmrData, locations)
%% this function take as input fmrData (128x128x128)
% and return the ansMat
% res = zeros(dimensions, dimensions, dimensions);
ansMat = zeros(size(locations,1),1);
for i = 1:size(locations,1)
%     res(locations(data(i,1),1),locations(data(i,1),2),locations(data(i,1),3)) = data(i,2);
    ansMat(i,1) = fmrData(locations(i,1),locations(i,2),locations(i,3));
end

ansMat = ansMat'; 
end
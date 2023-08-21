function ansMat = reverseScoringToMatrix1rowAnsMat(fmrData, locations)
%% this function take as input fmrData (128x128x128)
% and return the ansMat
% res = zeros(dimensions, dimensions, dimensions);

linearInd = sub2ind(size(fmrData), locations(:,1),  locations(:,2),  locations(:,3));
ansMat(:,1) = fmrData(linearInd); 

% for i = 1:size(locations,1)
% %     res(locations(data(i,1),1),locations(data(i,1),2),locations(data(i,1),3)) = data(i,2);
%     ansMat(i,1) = i;
%     ansMat(i,2) = fmrData(locations(i,1),locations(i,2),locations(i,3));
% end


end

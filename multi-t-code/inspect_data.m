function inspect_data(vxl,pc_funcData,evols,TR)
data_series=squeeze(pc_funcData(vxl(1),vxl(2),vxl(3),:));

figure;
hold on
plot(data_series)
for ev=1:length(evols)
    xline(evols(ev),'--r')
end

%find mean vol_of_peak
peakVol_vec=zeros(1,length(evols)-1);
for ev=1:length(evols)-1
    ev_data=data_series(evols(ev):ceil(evols(ev)+8/TR));
    peakVol_vec(ev)=find(ev_data==max(ev_data));
end
end

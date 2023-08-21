function plot_ruti_pvals(rutiPs,allpvals,uval,figfold,ARorder,idxlabels)
sigfdr = fdr_bh(rutiPs,0.05,'pdep','yes');
titlestr = sprintf('%d subs  u = %.2f  AR(%d)  (sig. regions in red)',...
                    size(allpvals,2),uval,ARorder);
figname =  sprintf('u-%.2f_AR-%d_subs-%d.pdf',...
                    uval,ARorder,size(allpvals,2));
%% plot box plots of pvalues (non ruti p values, raw p values) 
hfig = figure;
hfig.Position = [-1919         281        1920        1083];
hbox = boxplot(allpvals');
ax = gca;
ax.XTickLabelRotation = 70;
h=findobj(gca,'tag','Outliers'); % Get handles for outlier lines.
% make nice
title(titlestr); 
xlabel('area index'); 
ylabel('p-value'); 
b = findobj(gca,'tag','Box'); % returns in reverse order... 
idxsig = find(fliplr(sigfdr)==1); 
for i = 1:length(idxsig)
    b(idxsig(i)).LineWidth = 2;
    b(idxsig(i)).Color = [ 1 0 0];
end
set(gca,'XTickLabel',idxlabels)
fignameexp = fullfile(figfold,figname);
export_fig(fignameexp); 
end
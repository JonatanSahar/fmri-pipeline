function xnozeros = removezeros(x) 
xnozeros = x(:,sum(x,1)~=0);
end
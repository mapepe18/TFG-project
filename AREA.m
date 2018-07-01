Area = AREA(slice1:slice2);
Area_dif = diff(Area);
m = mean(Area_dif); sd = std(Area_dif);
p_sup = find(Area_dif>m+1.5*sd);
p_inf = find(Area_dif<m-1.5*sd)+1;
p = [p_sup;p_inf];
while isempty(p_sup)==0 && isempty(p_inf)==0
    Area_dif(p_sup) = m;
    Area_dif(p_inf) = m;
    p_sup = find(Area_dif>m+1.5*sd);
    p_inf = find(Area_dif<m-1.5*sd)+1;
    p = [p;p_sup;p_inf];
end
p = unique(p);
        

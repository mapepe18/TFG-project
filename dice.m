  mask = overflow;
mask1 = nnz(mask.CartilagueMasks);
mask2 = nnz(manual.CartilagueMasks);
inters = nnz(mask.CartilagueMasks.*manual.CartilagueMasks);
d = 2 * inters/(mask1+mask2)
%    DICE2_a = d
DICE2_a(end+1) = d
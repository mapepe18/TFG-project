
function Position = Reference_finder(reference_pos,target_pos)
% Position is a vector containing the indexes of the corresponding
% reference slice (the segmented slice)

N_target = numel(target_pos);
N_reference = numel(reference_pos);
Position = zeros(N_target,1);
for i = 1:N_target
    Distance = zeros(N_reference,1);
    for j = 1:N_reference
        Distance(j) = norm(target_pos{i}-reference_pos{j});
    end
    [val,pos] = min(Distance);
    Position(i) = pos;
end
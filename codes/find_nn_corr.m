function [neighbor_index] = find_nn_corr(corrs, p, voxel_ind)

[val, inds] = sort(corrs(voxel_ind,:), 'descend');

for k=1:length(p)
    neighbor_index{1,k} = inds(2:p+1);
    
end
end

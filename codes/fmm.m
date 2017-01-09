

%%
function [weights, mesh_errors]=fmm(corrs,p,data)

% M = number of voxels, N = number of samples
% corrs: M x M correlation matrix containing correlations of all pairs of voxels
% p: the number of neighboring voxels
% data: N x M data matrix

weights=[];
mesh_errors =[];

for i=1:size(data,2)% if size(tr_all)~=size(te_all), change here

    [neighbor_index] = find_nn_corr(corrs, p, i);

    x1=data(:,i);
    x2=data(:,neighbor_index{1,1});

    x=[x1 x2];
    [lpc_res, g] = lpc(x',p);
    zero_filled_weights = zeros(1,size(data,2));
    zero_filled_weights(neighbor_index{1,1}) = lpc_res(2:end);
  
    mesh_errors = [mesh_errors g];
   
    weights=[weights zero_filled_weights];
    
end
   


%%
function [weights, mesh_errors]=flm(corrs,p,data,lambda)

% M = number of voxels, N = number of samples
% corrs: M x M correlation matrix containing correlations of all pairs of voxels
% p: the number of neighboring voxels
% data: N x M data matrix
% lambda: regularization parameter of ridge regression

weights=[];
mesh_errors =[];

for i=1:size(data,2) 
    
    [neighbor_index] = find_nn_corr(corrs, p, i);
    
    y=data(:,i);
    X=data(:,neighbor_index{1,1});
    
    theta = ridge(y,X,lambda);
    err = sum((X*theta - y).*(X*theta - y));
    zero_filled_weights = zeros(1,size(data,2));
    zero_filled_weights(neighbor_index{1,1}) = theta';
       
    mesh_errors = [mesh_errors;err];
    
    weights=[weights zero_filled_weights];
    
end

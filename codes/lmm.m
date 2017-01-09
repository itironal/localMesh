

%%
function [weights, mesh_errors]=lmm(pos,p,data)

% M = number of voxels, N = number of samples
% pos: M x 3 matrix containing xyz coordinates of all voxels
% p: the number of neighboring voxels
% data: N x M data matrix

weights=[];
mesh_errors =[];

for i=1:size(data,2) 

    [neighbor_index] = find_nn(pos, pos(i,:), p);

    x1=data(:,i);
    x2=data(:,neighbor_index{1,1});

    x=[x1 x2];
    [lpc_res, g] = lpc(x',p);
    zero_filled_weights = zeros(1,size(data,2));
    zero_filled_weights(neighbor_index{1,1}) = lpc_res(2:end);
  
    mesh_errors = [mesh_errors g];
   
    weights=[weights zero_filled_weights];

end
   
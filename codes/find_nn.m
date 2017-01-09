function [neighbor_index] = find_nn(data, test, p)

num_train = size(data,1);
num_test  = size(test,1);


%% BEGIN kNN


for i=1:num_test
    distances = (repmat(test(i,:), num_train,1) - data).^2;
    % for efficiency, no need to take sqrt since it is a non-decreasing function
    distances = sum(distances,2)';
    
    % sort the distances
    [junk, inds] = sort(distances);
    
    for k=1:length(p)
        neighbor_index{i,k} = inds(2:p+1);       
    end
end
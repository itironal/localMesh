
function [] =  extract_weights(experiment, p_list, lambda_list)

 if ~exist('p_list','var')
      p_list = 5:5:30;
 end
 if ~exist('lambda_list','var')
      lambda_list = [8,16,32,64,128,256,512];
 end

all_files = dir('../data/*.mat');

load('../labels.mat');
[durations,unique_experiments] = hist(labels,unique(labels));
cum_durations = cumsum([1 durations]);
anatomical_region_inds = [1:8, 27:108]; % All regions excluding Cerebellum and Vermis regions.


if ( strcmp(experiment, 'flm') || strcmp(experiment, 'slm'))
    
    for p = p_list
        for lambda = lambda_list
            all_subjects_weights = [];
            mkdir(fullfile('../', [experiment '_weights'], ['p' num2str(p)], ['lambda' num2str(lambda)]));
            
            for subj = 1:numel(all_files)
                load(fullfile('../data', [all_files(subj).name ]));
                all_weights = [];
                
                for expr = 1:numel(unique_experiments)
                    chunk_data = data(cum_durations(expr): cum_durations(expr+1)-1 ,anatomical_region_inds);
                    weights = [];
                    if strcmp(experiment, 'flm')
                        [weights, mesh_errors] = flm(corr(chunk_data),p, chunk_data, lambda);
                    elseif strcmp(experiment, 'slm')
                        load('../reg_xyz_90.mat');
                        pos = reg_xyz;
                        [weights, mesh_errors] = slm(pos,p, chunk_data, lambda);
                    end
                    all_weights = [all_weights;weights];
                end
                all_subjects_weights = [all_subjects_weights;all_weights];
            end
            
            save(fullfile( '../', [experiment '_weights'], ['p' num2str(p)], ['lambda' num2str(lambda)], 'weights.mat'), 'all_subjects_weights');
            
        end
    end
end


if ( strcmp(experiment, 'fmm') || strcmp(experiment, 'lmm') || strcmp(experiment, 'fc'))
    
    for p = p_list
        
        all_subjects_weights = [];
        mkdir(fullfile('../', [experiment '_weights'], ['p' num2str(p)]));
        
        for subj = 1:numel(all_files)
            load(fullfile('../data', [all_files(subj).name ]));
            all_weights = [];
            
            for expr = 1:numel(unique_experiments)
                chunk_data = data(cum_durations(expr): cum_durations(expr+1)-1 ,anatomical_region_inds);
                mean_chunk = mean(chunk_data);

                weights = [];
                if strcmp(experiment, 'fmm')
                    [weights, mesh_errors]=fmm(corr(chunk_data),p, mean_chunk);

                elseif strcmp(experiment, 'lmm')
                    load('../reg_xyz_90.mat');
                    pos = reg_xyz;
                    [weights, mesh_errors] = lmm(pos,p, mean_chunk);
                elseif strcmp(experiment, 'fc')
                    feat = corr(chunk_data);
                    weights = feat(:)';
                    weights(isnan(weights)==1) = 0;
                end
                all_weights = [all_weights;weights];
            end
            all_subjects_weights = [all_subjects_weights;all_weights];
        end
        
        save(fullfile( '../', [experiment '_weights'], ['p' num2str(p)], 'weights.mat'), 'all_subjects_weights');
        
        
    end
end

disp('Weights are extracted.');

end

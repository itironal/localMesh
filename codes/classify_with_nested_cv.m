
function [] = classify_with_nested_cv(experiment, p_list, lambda_list, c_list)

if ~exist('p_list','var')
    p_list = 5:5:30;
end
if ~exist('lambda_list','var')
    lambda_list = [8,16,32,64,128,256,512];
end
if ~exist('c_list','var')
    c_list = [0.001, 0.01, 0.1, 1, 10, 100, 1000];
end


all_files = dir('../data/*.mat');
load('../labels.mat');

[durations,unique_experiments] = hist(labels,unique(labels));
classification_labels = repmat(unique_experiments, numel(all_files),1);

cum_durations = cumsum([1 durations]);
subject_sample_size = numel(unique_experiments);

outer_fold_no = 8;
inner_fold_no = outer_fold_no - 1;

number_of_subjects_in_fold = numel(all_files) / outer_fold_no;

final_accs = zeros(outer_fold_no,1);

if ( strcmp(experiment, 'flm') || strcmp(experiment, 'slm'))
    for i = 1:outer_fold_no
        
        te_run = i;
        te_inds = (i-1)*subject_sample_size * number_of_subjects_in_fold + 1: (i-1)*subject_sample_size * number_of_subjects_in_fold +  subject_sample_size * number_of_subjects_in_fold;
       
        all_inner_results = zeros(numel(p_list),numel(lambda_list),numel(c_list));
        
        for inner_fold = 1:inner_fold_no
            tr_val_runs = setdiff(1:outer_fold_no, te_run);
            val_run = tr_val_runs(inner_fold);
            val_inds = (val_run-1)*subject_sample_size * number_of_subjects_in_fold + 1: (val_run-1)*subject_sample_size * number_of_subjects_in_fold +  subject_sample_size * number_of_subjects_in_fold;
            tr_inds = setdiff(1: numel(all_files)*subject_sample_size, [val_inds;te_inds]);
            for p =1:numel(p_list)
                
                for lambda = 1:numel(lambda_list)
                    
                    disp(['outer_fold =' num2str(i)]);
                    disp(['inner_fold =' num2str(inner_fold)]);
                    disp(['p = ' num2str(p_list(p))]);
                    disp(['lambda = ' num2str(lambda_list(lambda))]);
                    
                    if (0 ==exist(fullfile('../', [experiment '_weights'], ['p' num2str(p_list(p))], ['lambda' num2str(lambda_list(lambda))], 'weights.mat')))
                        disp('weights.mat file does not exist. Extract weights first');
                        return
                    end
                    load(fullfile('../', [experiment '_weights'], ['p' num2str(p_list(p))], ['lambda' num2str(lambda_list(lambda))], 'weights.mat'));
                    
                    for c=1:numel(c_list)
                        model = train_linear(classification_labels(tr_inds), sparse(all_subjects_weights(tr_inds,:)), ['-c  ' num2str(c_list(c)), ' -s 2 -q' ] );
                        [predicted_label,accuracy_val,dec] = predict_linear(classification_labels(val_inds), sparse(all_subjects_weights(val_inds,:)), model, ' -q ');
                        all_inner_results(p,lambda,c) = all_inner_results(p,lambda,c) + accuracy_val(1);
                        
                        
                    end
                    
                end
            end
        end
        
        
        [maxval, I] = max(all_inner_results(:));
        [best_p,best_lambda,best_c] = ind2sub(size(all_inner_results),I);
        
        load(fullfile('../', [experiment '_weights'], ['p' num2str(p_list(best_p))], ['lambda' num2str(lambda_list(best_lambda))], 'weights.mat'));
        
        model = train_linear(classification_labels([tr_inds val_inds]), sparse(all_subjects_weights([tr_inds val_inds],:)), ['-c ' num2str(c_list(best_c)) ' -s 2 -q' ] );
        [predicted_label,final_accuracy_te,dec] = predict_linear(classification_labels(te_inds), sparse(all_subjects_weights(te_inds,:)), model,  ' -q ');
        final_accs(i) = final_accuracy_te(1);
    end
    
    mkdir(fullfile('../', 'classification_results', experiment));
    save(fullfile('../', 'classification_results', experiment, 'results.mat'), 'final_accs');
    
end

if ( strcmp(experiment, 'fmm') || strcmp(experiment, 'lmm') || strcmp(experiment, 'fc'))
    for i = 1:outer_fold_no
        
        te_run = i;
        te_inds = (i-1)*subject_sample_size * number_of_subjects_in_fold + 1: (i-1)*subject_sample_size * number_of_subjects_in_fold +  subject_sample_size * number_of_subjects_in_fold;
        
        all_inner_results = zeros(numel(p_list),numel(c_list));
        
        for inner_fold = 1:inner_fold_no
            tr_val_runs = setdiff(1:outer_fold_no, te_run);
            val_run = tr_val_runs(inner_fold);
            val_inds = (val_run-1)*subject_sample_size * number_of_subjects_in_fold + 1: (val_run-1)*subject_sample_size * number_of_subjects_in_fold +  subject_sample_size * number_of_subjects_in_fold;
            tr_inds = setdiff(1: numel(all_files)*subject_sample_size, [val_inds;te_inds]);
            for p =1:numel(p_list)
                
                disp(['outer_fold =' num2str(i)]);
                disp(['inner_fold =' num2str(inner_fold)]);
                disp(['p = ' num2str(p_list(p))]);
                
                if (0 == exist(fullfile('../', [experiment '_weights'], ['p' num2str(p_list(p))], 'weights.mat')))
                    disp('weights.mat file does not exist. Extract weights first');
                    return
                end
                load(fullfile('../', [experiment '_weights'], ['p' num2str(p_list(p))], 'weights.mat'));
                
                for c=1:numel(c_list)
                    model = train_linear(classification_labels(tr_inds), sparse(all_subjects_weights(tr_inds,:)), ['-c  ' num2str(c_list(c)), ' -s 2 -q' ] );
                    [predicted_label,accuracy_val,dec] = predict_linear(classification_labels(val_inds), sparse(all_subjects_weights(val_inds,:)), model, ' -q ');
                    all_inner_results(p,c) = all_inner_results(p,c) + accuracy_val(1);
                    
                end
                
            end
        end
        
        
        [maxval, I] = max(all_inner_results(:));
        [best_p,best_c] = ind2sub(size(all_inner_results),I);
        
        load(fullfile('../', [experiment '_weights'], ['p' num2str(p_list(best_p))],  'weights.mat'));
        
        model = train_linear(classification_labels([tr_inds val_inds]), sparse(all_subjects_weights([tr_inds val_inds],:)), ['-c ' num2str(c_list(best_c)) ' -s 2 -q' ] );
        [predicted_label,final_accuracy_te,dec] = predict_linear(classification_labels(te_inds), sparse(all_subjects_weights(te_inds,:)), model,  ' -q ');
        final_accs(i) = final_accuracy_te(1);
    end
    
    mkdir(fullfile('../', 'classification_results', experiment));
    save(fullfile('../', 'classification_results', experiment, 'results.mat'), 'final_accs');
    
end
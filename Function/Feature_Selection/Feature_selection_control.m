function [feature_rank]=Feature_selection_control(Md,option)
    switch(option)
        case 'Random Forest'
           feature_rank=Featureimportance(Md); 
    end
end
function [feature_rank]=Featureimportance(Md)
%     paroptions = statset('UseParallel',false);
    if iscell(Md)
        for i=1:length(Md)
            try
                permutation(i,:)=oobPermutedPredictorImportance(Md{i});
                feature_importance(i,:)=predictorImportance(Md{i});
            catch ME
                continue
            end
        end
    else
        permutation=oobPermutedPredictorImportance(Md);
        feature_importance=predictorImportance(Md);
    end
    feature_rank{1}=permutation;
    feature_rank{2}=feature_importance;
end


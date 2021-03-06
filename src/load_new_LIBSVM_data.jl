# include("./dataLoad.jl")
using SparseArrays
include("./src/dataLoad.jl")
default_path = "./data/";
initDetails(default_path)


datasets = ["name-of-libsvm-dataset-to-load"]
# already loaded: "covtype_binary", "YearPredictionMSD_full", "rcv1_full", "news20_binary", "slice", "real-sim", "ijcnn1_full", "a1a_full", "colon-cancer"

## WARNING: be careful and select properly the following setting!
# classification = false; # Regression
classification = true; # Binary classification
for dataset in datasets
    try
        X, y = loadDataset(default_path, dataset);
        saveDetails(default_path, dataset, X); # In case it was not previously done
    catch loaderror
        # println(loaderror);
        println("failed to load: ", "$(default_path)$(dataset).jld");
        transformDataJLD(default_path,dataset, classification); # 2nd arg = classification
        X, y = loadDataset(default_path, dataset);
    end
    lines = readlines("$(default_path)available_datasets.txt");
    if !(dataset in lines)
        println("Writing its name in: ", "$(default_path)available_datasets.txt");
        open("$(default_path)available_datasets.txt", "a") do file
            write(file, "$(dataset)\n");
        end
    end
    showDetails(default_path, dataset);
end
load("$(default_path)details.jld")

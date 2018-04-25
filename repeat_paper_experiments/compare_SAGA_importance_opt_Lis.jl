using JLD
using Plots
using StatsBase
using Match
include("../src/StochOpt.jl")

## Basic parameters and options for solvers
options = set_options(max_iter=10^8, max_time = 5.0, max_epocs = 50,  repeat_stepsize_calculation = true, regulatrizor_parameter="1/num_data"); # =100, ,skip_error_calculation =5
options.batchsize =1;
## load data

numdata = 1000;
numfeatures =numdata;
lambda_input = 1/(numdata^2);
a =1./numdata;
  # X, y, probname = gen_diag_lone_eig_data(numfeatures, numdata, lambda = lambda_input, a =1/lambda_input );
 # X, y, probname = gen_gauss_data(numfeatures, numdata, lambda = lambda_input);
X, y, probname = gen_gauss_scaled_data(numfeatures, numdata, lambda = 0.0, Lmin = a, err =  10.0^(-3));
# Data tested in paper: w8a mushrooms gisette_scale,  madelon  a9a  phishing  covtype splice  rcv1_train  liver-disorders_scale
prob =   load_ridge_regression(X, y, probname, options, lambda = lambda_input,  normalize = false);  # Loads logisitc problem
#
## Running methods
OUTPUTS = [];  # List of saved outputs
# # # #
# #####
# # # #
SAGA_li = intiate_SAGA(prob , options, minibatch_type = "partition", probability_type= "Li")
output= minimizeFunc(prob, SAGA_li, options);
OUTPUTS = [OUTPUTS ; output];
# # #####
SAGA_opt = intiate_SAGA(prob , options, minibatch_type = "partition", probability_type= "opt")
output= minimizeFunc(prob, SAGA_opt, options);
OUTPUTS = [OUTPUTS ; output];
####
SAGA = intiate_SAGA(prob , options, minibatch_type = "partition", probability_type= "uni")
output= minimizeFunc(prob, SAGA, options);
OUTPUTS = [OUTPUTS ; output];
####
# # #
default_path = "./data/";   savename= replace(replace(prob.name, r"[\/]", "-"),".","_");
save("$(default_path)$(savename).jld", "OUTPUTS",OUTPUTS);

pyplot()# gr() pyplot() # pgfplots() #plotly()
plot_outputs_Plots(OUTPUTS,prob,options) # Plot and save output
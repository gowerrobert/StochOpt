## Load and plot previously saved data.
using JLD
using Plots
using StatsBase
using Match
include("../src/StochOpt.jl")

## Set default options and parameters
options = set_options();

## load problem
datapath = ""#
# probnames = ["phishing", "madelon",  "a9a",  "mushrooms", "phishing", "w8a", "gisette_scale"  ,"covtype"]#  rcv1_train  liver-disorders_scale
probname ="mushrooms";
# for probname in probnames
  # probname = "madelon";
  # name = string("lgstc_",  probname);
  # beststep, savename = get_saved_stepsize(prob.name, method_name,options);
   prob = load_logistic(probname, datapath, options);
   options.batchsize = prob.numdata;
   load_fsol!(options, prob);  # load a pre-calculated best  solution
   default_path = "./data/";   loadname= replace(prob.name, r"[\/]", "-");
   OUTPUTS = load("$(default_path)$(loadname).jld", "OUTPUTS");
##  Some code for editing which methods are plotted
      OUTPUTNEW = OUTPUTS[1:end-2];
     # OUTPUTNEW = [OUTPUTNEW ; OUTPUTS[4:end]];
     # OUTPUTNEW = [OUTPUTNEW ; OUTPUTS[end]];
  pyplot()# gr() pyplot() # pgfplots() #plotly()
  plot_outputs_Plots(OUTPUTNEW, prob, options, 15)
 # end

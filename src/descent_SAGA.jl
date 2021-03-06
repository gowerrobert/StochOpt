# /!\ WARNING: useless "N" ... it should be removed
function descent_SAGA(x::Array{Float64}, prob::Prob, options::MyOptions, sg::SAGAmethod, N::Int64, d::Array{Float64})
    s = sample(1:prob.numdata, options.batchsize, replace=false);
    if(sg.minibatch_type == "rade") #Take the averaged of the gradients then broadcast to the columns of Jac
        sg.aux[:] = -sum(sg.Jac[:, s], 2);
        sg.gi[:] = prob.g_eval(x, s);
        sg.aux[:] += options.batchsize*sg.gi; # calculating the update vector   (DF^k-J^k) Proj 1
        sg.Jac[:, s] .= sg.gi;
        ## Need to adapt this rade/broadcast implementation to the new generalize linear model setup
        # scalargrad = prob.scalar_grad_eval(x,s);
        # sg.gi[:] = (prob.X[:,s])*scalargrad;
        # sg.aux[:]  = -(prob.X[:,s])*sg.Jac[s];
        # sg.aux[:]  +=  sg.gi; # calculating the update vector   (DF^k-J^k) Proj 1
        # sg.Jac[s]  =  mean(scalargrad);
    else  #Assign each gradient to a different column of Jac
        # sg.aux[:]  =  -sum(sg.Jac[:,s],2); # calculating the update vector   (DF^k-J^k) Proj 1
        # prob.Jac_eval!(x,s,sg.Jac);
        # sg.aux[:]  += sum(sg.Jac[:,s],2);
        scalargrad = prob.scalar_grad_eval(x, s);
        sg.gi[:] = (prob.X[:, s])*scalargrad;
        #  calculating the update vector (DF^k-J^k) Proj 1
        sg.aux[:] = -(prob.X[:, s])*sg.Jac[s]; # - sum_{i\in S_k} J_ {:i}^k
        sg.aux[:] += sg.gi; # + sum_{i\in S_k} grad f_i (x^k)
        sg.Jac[s] = scalargrad;
    end

    # Gradient estimate
    # Update of the unbiased gradient estimate g^k
    if(sg.unbiased)
        d[:] = -sg.SAGgrad - (1/options.batchsize)*sg.aux;
    else
        d[:] = -sg.SAGgrad; #- (1/options.batchsize)*sg.aux;
    end

    # Update SAG estimate:   1/n J^{k+1}1 = 1/n J^k 1 + 1/n (DF^k-J^k) Proj 1
    # Update of the biased gradient estimate v^k
    sg.SAGgrad[:] = sg.SAGgrad + (1/prob.numdata)*sg.aux;
end

%% Simulations
Poisson_rate=10000;

params.sim_length=1000;
params.Enoise=0;
params.Inoise=0;
params.ErPoissonAMPA=Poisson_rate;
params.EgPoissonAMPA=0;
params.ErPoissonGABAA=Poisson_rate;
params.EgPoissonGABAA=0;
params.IrPoissonAMPA=Poisson_rate;
params.IgPoissonAMPA=0;
params.IrPoissonGABAA=Poisson_rate;
params.IgPoissonGABAA=0;
params.ErPoissonAMPA=Poisson_rate;

sPING_network_iPoisson(params)

%% Analysis

clear data eqns s
load(['sPING_' num2str(params.sim_length) 'ms_' num2str(params.ErPoissonAMPA) '_' ...
    num2str(params.IrPoissonAMPA) 'rAMPA_' num2str(params.EgPoissonAMPA) '_' ...
    num2str(params.IgPoissonAMPA) 'gAMPA_' num2str(params.ErPoissonGABAA) '_' ...
    num2str(params.IrPoissonGABAA) 'rGABAA_' num2str(params.EgPoissonGABAA) '_' ...
    num2str(params.IgPoissonGABAA) 'gGABAA.mat'])
[f,P]=power_spectrum(mean(data.E_I_iGABAa_ISYN(30001:end,:),2));
figure;loglog(f,P)
figure;plot(f,P)
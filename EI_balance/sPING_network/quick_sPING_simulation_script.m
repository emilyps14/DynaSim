%% Simulations
Poisson_rate=10000;

params.sim_length=1000;
params.Enoise=0; %40 originally
params.Inoise=0; %40 originally
params.ErPoissonAMPA=Poisson_rate;
params.EgPoissonAMPA=0; % 0.005
params.ErPoissonGABAA=Poisson_rate;
params.EgPoissonGABAA=0;% 0.00001
params.IrPoissonAMPA=Poisson_rate;
params.IgPoissonAMPA=0; %0.005
params.IrPoissonGABAA=Poisson_rate;
params.IgPoissonGABAA=0; %0.00001
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
% xlim([0 500])
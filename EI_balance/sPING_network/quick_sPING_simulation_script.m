%% Simulations
sim_length=1000;
Poisson_rate=10000;
EgAMPA1=0.005;
EgGABAA1=0.00001;
IgAMPA1=0.005;
IgGABAA1=0.00001;

sPING_network_iPoisson(sim_length,Poisson_rate,EgAMPA1,Poisson_rate,EgGABAA1,Poisson_rate,IgAMPA1,Poisson_rate,IgGABAA1)

%% Analysis

clear data eqns s
load(['sPING_' num2str(sim_length) 'ms_' num2str(Poisson_rate) '_' ...
    num2str(Poisson_rate) 'rAMPA_' num2str(EgAMPA1) '_' ...
    num2str(IgAMPA1) 'gAMPA_' num2str(Poisson_rate) '_' ...
    num2str(Poisson_rate) 'rGABAA_' num2str(EgGABAA1) '_' ...
    num2str(IgGABAA1) 'gGABAA.mat'])
[f,P]=power_spectrum(mean(data.E_I_iGABAa_ISYN(10001:end,:),2));
figure;loglog(f,P)
figure;plot(f,P)
% xlim([0 500])
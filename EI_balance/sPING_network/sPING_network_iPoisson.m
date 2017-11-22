function sPING_network_iPoisson(params)
% Taken from the Sparse Pyramidal-Interneuron-Network-Gamma (sPING) section
% in dsDemos.m
% sim_length is the length of the simulation [ms]. In the rest of the
% variable names, E refers to inputs to pyramidal neurons, I refers to
% inputs to interneurons, r refers to rate [Hz], and g refers to
% conductance.

if isempty(params.sim_length)
    params.sim_length=1000;
end
if isempty(params.Enoise)
    params.Enoise=40;
end
if isempty(params.Inoise)
    params.Inoise=40;
end
if isempty(params.ErPoissonAMPA)
    params.ErPoissonAMPA=10000;
end
if isempty(params.EgPoissonAMPA)
    params.EgPoissonAMPA=0.005;
end
if isempty(params.ErPoissonGABAA)
    params.ErPoissonGABAA=10000;
end
if isempty(params.EgPoissonGABAA)
    params.EgPoissonGABAA=0;
end
if isempty(params.IrPoissonAMPA)
    params.IrPoissonAMPA=10000;
end
if isempty(params.IgPoissonAMPA)
    params.IgPoissonAMPA=0;
end
if isempty(params.IrPoissonGABAA)
    params.IrPoissonGABAA=10000;
end
if isempty(params.IgPoissonGABAA)
    params.IgPoissonGABAA=0;
end

% define equations of cell model (same for E and I populations)
eqns={
  'dv/dt=Iapp+@current+noise*randn(1,N_pop)'
  'monitor iGABAa.functions, iAMPA.functions, iPoissonAMPA.functions, iPoissonGABAA.functions'
};
% Tip: monitor all functions of a mechanism using: monitor MECHANISM.functions

% create DynaSim specification structure
s=[];
s.populations(1).name='E';
s.populations(1).size=80;
s.populations(1).equations=eqns;
s.populations(1).mechanism_list={'iNa','iK','iPoissonAMPA','iPoissonGABAA'};
s.populations(1).parameters={'Iapp',0,'gNa',120,'gK',36,'noise',params.Enoise,'DCAMPA',params.ErPoissonAMPA,'gextAMPA',params.EgPoissonAMPA,'EextAMPA',0,'DCGABAA',params.ErPoissonGABAA,'gextGABAA',params.EgPoissonGABAA,'EextGABAA',-80};
s.populations(2).name='I';
s.populations(2).size=20;
s.populations(2).equations=eqns;
s.populations(2).mechanism_list={'iNa','iK','iPoissonAMPA','iPoissonGABAA'};
s.populations(2).parameters={'Iapp',0,'gNa',120,'gK',36,'noise',params.Inoise,'DCAMPA',params.IrPoissonAMPA,'gextAMPA',params.IgPoissonAMPA,'EextAMPA',0,'DCGABAA',params.IrPoissonGABAA,'gextGABAA',params.IgPoissonGABAA,'EextGABAA',-80};
s.connections(1).direction='I->E';
s.connections(1).mechanism_list={'iGABAa'};
s.connections(1).parameters={'tauD',10,'gSYN',.1,'netcon','ones(N_pre,N_post)'};
s.connections(2).direction='E->I';
s.connections(2).mechanism_list={'iAMPA'};
s.connections(2).parameters={'tauD',2,'gSYN',.1,'netcon',ones(80,20)};

data=dsSimulate(s,'tspan',[0 params.sim_length], 'study_dir','demo_sPING_0');

dsPlot(data);
dsPlot(data,'variable',{'V','gPoissonAMPA'});
dsPlot(data,'variable',{'V','gPoissonGABAA'});

clear ans

save(['sPING_' num2str(params.sim_length) 'ms_' num2str(params.ErPoissonAMPA) '_' ...
    num2str(params.IrPoissonAMPA) 'rAMPA_' num2str(params.EgPoissonAMPA) '_' ...
    num2str(params.IgPoissonAMPA) 'gAMPA_' num2str(params.ErPoissonGABAA) '_' ...
    num2str(params.IrPoissonGABAA) 'rGABAA_' num2str(params.EgPoissonGABAA) '_' ...
    num2str(params.IgPoissonGABAA) 'gGABAA.mat'],'-v7.3')

% % View the connection mechanism file:
% [~,eqnfile]=dsLocateModelFiles('iAMPA.mech'); edit(eqnfile{1});
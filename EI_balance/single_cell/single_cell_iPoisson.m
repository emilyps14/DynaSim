function single_cell_iPoisson(sim_length,ErPoissonAMPA,EgPoissonAMPA,ErPoissonGABAA,EgPoissonGABAA,IrPoissonAMPA,IgPoissonAMPA,IrPoissonGABAA,IgPoissonGABAA)
% Taken from the Sparse Pyramidal-Interneuron-Network-Gamma (sPING) section
% in dsDemos.m
% sim_length is the length of the simulation [ms]. In the rest of the
% variable names, E refers to inputs to pyramidal neurons, I refers to
% inputs to interneurons, r refers to rate [Hz], and g refers to
% conductance.

% define equations of cell model (same for E and I populations)
eqns={
  'dv/dt=Iapp+@current+noise*randn(1,N_pop)'
  'monitor iGABAa.functions, iAMPA.functions, iPoissonAMPA.functions, iPoissonGABAA.functions'
};
% Tip: monitor all functions of a mechanism using: monitor MECHANISM.functions

% create DynaSim specification structure
s=[];
s.populations(1).name='E';
s.populations(1).size=1;
s.populations(1).equations=eqns;
s.populations(1).mechanism_list={'iNa','iK','iPoissonAMPA','iPoissonGABAA'};
s.populations(1).parameters={'Iapp',0,'gNa',120,'gK',36,'noise',0,'DCAMPA',ErPoissonAMPA,'gextAMPA',EgPoissonAMPA,'EextAMPA',0,'DCGABAA',ErPoissonGABAA,'gextGABAA',EgPoissonGABAA,'EextGABAA',-80};
s.populations(2).name='I';
s.populations(2).size=1;
s.populations(2).equations=eqns;
s.populations(2).mechanism_list={'iNa','iK','iPoissonAMPA','iPoissonGABAA'};
s.populations(2).parameters={'Iapp',0,'gNa',120,'gK',36,'noise',0,'DCAMPA',IrPoissonAMPA,'gextAMPA',IgPoissonAMPA,'EextAMPA',0,'DCGABAA',IrPoissonGABAA,'gextGABAA',IgPoissonGABAA,'EextGABAA',-80};
% s.connections(1).direction='I->E';
% s.connections(1).mechanism_list={'iGABAa'};
% s.connections(1).parameters={'tauD',10,'gSYN',.1,'netcon','ones(N_pre,N_post)'};
% s.connections(2).direction='E->I';
% s.connections(2).mechanism_list={'iAMPA'};
% s.connections(2).parameters={'tauD',2,'gSYN',.1,'netcon',ones(80,20)};

data=dsSimulate(s,'tspan',[0 sim_length], 'study_dir','demo_sPING_0');

dsPlot(data);
dsPlot(data,'variable',{'V','gPoissonAMPA'});
dsPlot(data,'variable',{'V','gPoissonGABAA'});

clear ans

save(['sPING_' num2str(sim_length) 'ms_' num2str(ErPoissonAMPA) '_' ...
    num2str(IrPoissonAMPA) 'rAMPA_' num2str(EgPoissonAMPA) '_' ...
    num2str(IgPoissonAMPA) 'gAMPA_' num2str(ErPoissonGABAA) '_' ...
    num2str(IrPoissonGABAA) 'rGABAA_' num2str(EgPoissonGABAA) '_' ...
    num2str(IgPoissonGABAA) 'gGABAA.mat'],'-v7.3')

% % View the connection mechanism file:
% [~,eqnfile]=dsLocateModelFiles('iAMPA.mech'); edit(eqnfile{1});
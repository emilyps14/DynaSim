params.sim_length=10000; % [ms]
Poisson_rate=1000; % [Hz] for all external Poisson input
EgAMPA=0.05:0.05:0.5;
IgAMPA=0.05:0.05:0.5;
EgGABAA=0.05:0.05:0.5;
IgGABAA=0.05:0.05:0.5;
eiratio=zeros(length(EgAMPA),length(EgGABAA));

for k=1:length(EgAMPA) % conductance range for external AMPA input
    for o=1:length(EgGABAA) % conductance range for external GABAA input
        params.ErPoissonAMPA=Poisson_rate;
        params.EgPoissonAMPA=EgAMPA(k);
        params.ErPoissonGABAA=Poisson_rate;
        params.EgPoissonGABAA=EgGABAA(o);
        params.IrPoissonAMPA=Poisson_rate;
        params.IgPoissonAMPA=IgAMPA(k);
        params.IrPoissonGABAA=Poisson_rate;
        params.IgPoissonGABAA=IgGABAA(o);
        
        %run simulation
        sPING_network_iPoisson(sim_length,Poisson_rate,EgAMPA(k),Poisson_rate,...
            EgGABAA(o),Poisson_rate,IgAMPA(k),Poisson_rate,IgGABAA(o))
        
        clear data eqns s
        load(['sPING_' num2str(params.sim_length) 'ms_' num2str(params.ErPoissonAMPA) '_' ...
            num2str(params.IrPoissonAMPA) 'rAMPA_' num2str(params.EgPoissonAMPA) '_' ...
            num2str(params.IgPoissonAMPA) 'gAMPA_' num2str(params.ErPoissonGABAA) '_' ...
            num2str(params.IrPoissonGABAA) 'rGABAA_' num2str(params.EgPoissonGABAA) '_' ...
            num2str(params.IgPoissonGABAA) 'gGABAA.mat'])
        eiratio(k,o)=mean(data.E_iPoissonAMPA_gPoissonAMPA)/mean(data.E_iPoissonGABAA_gPoissonGABAA);
        
        % compute power spectra of intranetwork and external synaptic currents
        [f_intranetwork_syn,P_intranetwork_syn]=power_spectrum(mean(data.E_I_iGABAa_ISYN(10001:end,:),2)); % only GABA since intranetwork synpatic AMPA is not in pyramidal neurons
        [f_applied_syn,P_applied_syn]=power_spectrum(mean(data.E_iPoissonAMPA_IPoissonAMPA(10001:end,:)+data.E_iPoissonGABAA_IPoissonGABAA(10001:end,:),2)); % only external Poisson inputs to pyramidal neurons
        
        % compute linear regression of 30-50 Hz for both intranetwork and external synaptic currents
        fitstats_intranetwork_syn(k,o)=regstats(log10(P_intranetwork_syn(80:132)),log10(f_intranetwork_syn(80:132)),'linear',{'yhat','rsquare','beta'});
        PSDslopes_intranetwork_syn(k,o)=fitstats_intranetwork_syn(k,o).beta(2);
        fitstats_applied_syn(k,o)=regstats(log10(P_applied_syn(80:132)),log10(f_applied_syn(80:132)),'linear',{'yhat','rsquare','beta'});
        PSDslopes_applied_syn(k,o)=fitstats_applied_syn(k,o).beta(2);
        
        % plot power spectra with regression line for both intranetwork and external synaptic currents
        figure;loglog(f_intranetwork_syn,P_intranetwork_syn)
        hold on;plot(f(80:132),10.^fitstats_intranetwork_syn(k,o).yhat,'r','linewidth',2)
        title({['E:I ratio (to pyramidal neurons): ' ...
            num2str(eiratio(k,o))] ['30-50 Hz log-log slope: ' num2str(PSDslopes_intranetwork_syn(k,o))]})
        xlabel('frequency [Hz]')
        ylabel('power')
        figure;loglog(f_applied_syn,P_applied_syn)
        hold on;plot(f(80:132),10.^fitstats_applied_syn(k,o).yhat,'r','linewidth',2)
        title({['E:I ratio (to pyramidal neurons): ' ...
            num2str(eiratio(k,o))] ['30-50 Hz log-log slope: ' num2str(PSDslopes_applied_syn(k,o))]})
        xlabel('frequency [Hz]')
        ylabel('power')
        
        % save figure
%         print(['sPING_' num2str(params.sim_length) 'ms_' num2str(params.ErPoissonAMPA) '_' ...
%             num2str(params.IrPoissonAMPA) 'rAMPA_' num2str(params.EgPoissonAMPA) '_' ...
%             num2str(params.IgPoissonAMPA) 'gAMPA_' num2str(params.ErPoissonGABAA) '_' ...
%             num2str(params.IrPoissonGABAA) 'rGABAA_' num2str(params.EgPoissonGABAA) '_' ...
%             num2str(params.IgPoissonGABAA) 'gGABAA.png'],'-dpng')
        close all
    end
end

save('EIstats.mat','eiratio','PSDslopes_intranetwork_syn','fitstats_intranetwork_syn','PSDslopes_applied_syn','fitstats_applied_syn')

figure;imagesc(EgAMPA,EgGABAA,PSDslopes_intranetwork_syn)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
figure;imagesc(EgAMPA,EgGABAA,PSDslopes_applied_syn)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
figure;imagesc(EgAMPA,EgGABAA,eiratio)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
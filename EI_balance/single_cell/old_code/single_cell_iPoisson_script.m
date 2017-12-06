sim_length=10000; % [ms]
Poisson_rate_AMPA=16000; % [Hz] for all external Poisson input
Poisson_rate_GABAA=10000; % [Hz] for all external Poisson input
EgAMPA=0.00005:0.00005:0.0005;
IgAMPA=0.00005:0.00005:0.0005;
EgGABAA=0.00005:0.00005:0.0005;
IgGABAA=0.00005:0.00005:0.0005;
eiratio=zeros(length(EgAMPA),length(EgGABAA));

for k=1:length(EgAMPA) % conductance range for external AMPA input
    for o=1:length(EgGABAA) % conductance range for external GABAA input
        single_cell_iPoisson(sim_length,Poisson_rate_AMPA,EgAMPA(k),Poisson_rate_GABAA,...
            IgGABAA(o),Poisson_rate_AMPA,IgAMPA(k),Poisson_rate_GABAA,IgGABAA(o))
        
        clear data eqns s
        load(['sPING_' num2str(sim_length) 'ms_' num2str(Poisson_rate_AMPA) '_' ...
            num2str(Poisson_rate_AMPA) 'rAMPA_' num2str(EgAMPA(k)) '_' ...
            num2str(IgAMPA(k)) 'gAMPA_' num2str(Poisson_rate_GABAA) '_' ...
            num2str(Poisson_rate_GABAA) 'rGABAA_' num2str(EgGABAA(o)) '_' ...
            num2str(IgGABAA(o)) 'gGABAA.mat'])
        eiratio(k,o)=mean(data.E_iPoissonAMPA_gPoissonAMPA)/mean(data.E_iPoissonGABAA_gPoissonGABAA);
        [f_applied_syn,P_applied_syn]=power_spectrum(mean(data.E_iPoissonAMPA_IPoissonAMPA(10001:end,:)+data.E_iPoissonGABAA_IPoissonGABAA(10001:end,:),2)); % only external Poisson inputs to pyramidal neurons
%         [f_spiking,P_spiking]=power_spectrum(mean(data.(10001:end,:),2)); % spiking currents
        fitstats_applied_syn(k,o)=regstats(log10(P_applied_syn(80:132)),log10(f_applied_syn(80:132)),'linear',{'yhat','rsquare','beta'});
        PSDslopes_applied_syn(k,o)=fitstats_applied_syn(k,o).beta(2);
        figure;loglog(f_applied_syn,P_applied_syn)
        hold on;plot(f_applied_syn(80:132),10.^fitstats_applied_syn(k,o).yhat,'r','linewidth',2)
        title({['E:I ratio (to pyramidal neurons): ' ...
            num2str(eiratio(k,o))] ['30-50 Hz log-log slope: ' num2str(PSDslopes_applied_syn(k,o))]})
        xlabel('frequency [Hz]')
        ylabel('power')
        print(['sPING_' num2str(sim_length) 'ms_' num2str(Poisson_rate_AMPA) '_' ...
            num2str(Poisson_rate_GABAA) 'rAMPA_' num2str(EgAMPA(k)) '_' ...
            num2str(IgAMPA(k)) 'gAMPA_' num2str(Poisson_rate_AMPA) '_' ...
            num2str(Poisson_rate_GABAA) 'rGABAA_' num2str(EgGABAA(o)) '_' ...
            num2str(IgGABAA(o)) 'gGABAA.png'],'-dpng')
        close all
    end
end

save('EIstats.mat','eiratio','PSDslopes_applied_syn','fitstats_applied_syn')

figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,PSDslopes_applied_syn)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,eiratio)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
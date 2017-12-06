sim_length=5000; % [ms]
Poisson_rate_AMPA=16000; % [Hz] for all external Poisson input
Poisson_rate_GABAA=10000; % [Hz] for all external Poisson input
gAMPA=0.00005:0.00005:0.0005;
gGABAA=0.00005:0.00005:0.0005;
eiratio=zeros(length(gAMPA),length(gGABAA));

for k=1:length(gAMPA) % conductance range for external AMPA input
    for o=1:length(gGABAA) % conductance range for external GABAA input
        eqns={'dv/dt=Iapp+@current; {iNa,iK,iPoissonAMPA,iPoissonGABAA};'
            'Iapp=0;'
            'gNa=120;'
            'gK=36;'
            'noise=0;'
            ['DCAMPA=' num2str(Poisson_rate_AMPA)]
            ['gextAMPA=' num2str(gAMPA(k))]
            'EextAMPA=0;'
            ['DCGABAA=' num2str(Poisson_rate_GABAA)]
            ['gextGABAA=' num2str(gGABAA(o))]
            'EextGABAA=-80;'
            'monitor iPoissonAMPA.functions, iPoissonGABAA.functions'
            };
        data=dsSimulate(eqns,'tspan',[0 sim_length]);
        eiratio(k,o)=mean(data.pop1_iPoissonAMPA_gPoissonAMPA)/mean(data.pop1_iPoissonGABAA_gPoissonGABAA);
        [f,P]=power_spectrum(data.pop1_iPoissonAMPA_IPoissonAMPA(50001:end,:)+data.pop1_iPoissonGABAA_IPoissonGABAA(50001:end)); % only external Poisson inputs to pyramidal neurons
%         [f_spiking,P_spiking]=power_spectrum(mean(data.pop1_iK_IK(10001:end,:)+data.pop1_iNa_INa(50001:end,:),2)); % spiking currents
        fitstats(k,o)=regstats(log10(P(210:end)),log10(f(210:end)),'linear',{'yhat','rsquare','beta'}); %f(158:263) ~ 30-50 Hz
        PSDslopes(k,o)=fitstats(k,o).beta(2);
        figure;loglog(f,P)
        hold on;plot(f(210:end),10.^fitstats(k,o).yhat,'r','linewidth',2)
        title({['E:I ratio (to pyramidal neurons): ' ...
            num2str(eiratio(k,o))] ['30-50 Hz log-log slope: ' num2str(PSDslopes(k,o))]})
        xlabel('frequency [Hz]')
        ylabel('power')
        print(['single_cell_' num2str(sim_length) 'ms_' num2str(Poisson_rate_AMPA) 'rAMPA_' ...
            num2str(gAMPA(k)) 'gAMPA_' num2str(Poisson_rate_GABAA) 'rGABAA_' ...
            num2str(gGABAA(o)) 'gGABAA.png'],'-dpng')
        close all
    end
end

save('EIstats.mat','eiratio','PSDslopes','fitstats')

figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,PSDslopes)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,eiratio)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
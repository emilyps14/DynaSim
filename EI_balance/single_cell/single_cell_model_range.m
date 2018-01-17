sim_length=20000; % [ms]
Poisson_rate_AMPA=10000; % [Hz] for all external Poisson input
Poisson_rate_GABAA=10000; % [Hz] for all external Poisson input
gAMPA=0.00005:0.00005:0.0005;
gGABAA=0.00005:0.00005:0.0005;
eiratio=zeros(length(gAMPA),length(gGABAA));
fAMPA=zeros(length(gAMPA),length(gGABAA),3146);
PAMPA=zeros(length(gAMPA),length(gGABAA),3146);
fGABAA=zeros(length(gAMPA),length(gGABAA),3146);
PGABAA=zeros(length(gAMPA),length(gGABAA),3146);
f=zeros(length(gAMPA),length(gGABAA),3146);
P=zeros(length(gAMPA),length(gGABAA),3146);

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
        [fAMPA(k,o,:),PAMPA(k,o,:)]=power_spectrum(data.pop1_iPoissonAMPA_IPoissonAMPA(50001:end,:)); % only external Poisson inputs to pyramidal neurons
        [fGABAA(k,o,:),PGABAA(k,o,:)]=power_spectrum(data.pop1_iPoissonGABAA_IPoissonGABAA(50001:end)); % only external Poisson inputs to pyramidal neurons
        [f(k,o,:),P(k,o,:)]=power_spectrum(data.pop1_iPoissonAMPA_IPoissonAMPA(50001:end,:)+data.pop1_iPoissonGABAA_IPoissonGABAA(50001:end)); % only external Poisson inputs to pyramidal neurons
%         [f_spiking,P_spiking]=power_spectrum(mean(data.pop1_iK_IK(10001:end,:)+data.pop1_iNa_INa(50001:end,:),2)); % spiking currents
        fitstatsAMPA(k,o)=regstats(log10(reshape(PAMPA(k,o,210:end),1,[])),log10(reshape(fAMPA(k,o,210:end),1,[])),'linear',{'yhat','rsquare','beta'}); %f(k,o,1050:end) ~ 30-50 Hz
        fitstatsGABAA(k,o)=regstats(log10(reshape(PGABAA(k,o,210:end),1,[])),log10(reshape(fGABAA(k,o,210:end),1,[])),'linear',{'yhat','rsquare','beta'}); %f(k,o,1050:end) ~ 30-50 Hz
        fitstats(k,o)=regstats(log10(reshape(P(k,o,210:end),1,[])),log10(reshape(f(k,o,210:end),1,[])),'linear',{'yhat','rsquare','beta'}); %f(k,o,1050:end) ~ 30-50 Hz
        PSDslopesAMPA(k,o)=fitstatsAMPA(k,o).beta(2);
        PSDslopesGABAA(k,o)=fitstatsGABAA(k,o).beta(2);
        PSDslopes(k,o)=fitstats(k,o).beta(2);
%         hfig=figure;hfig.Visible='off';loglog(reshape(f(k,o,:),1,[]),reshape(P(k,o,:),1,[]));
%         hold on;plot(reshape(f(k,o,210:end),1,[]),10.^fitstats(k,o).yhat,'r','linewidth',2)
%         title({['E:I ratio (to pyramidal neurons): ' ...
%             num2str(eiratio(k,o))] ['30-50 Hz log-log slope: ' num2str(PSDslopes(k,o))]})
%         xlabel('frequency [Hz]')
%         ylabel('power')
%         print(['single_cell_' num2str(sim_length) 'ms_' num2str(Poisson_rate_AMPA) 'rAMPA_' ...
%             num2str(gAMPA(k)) 'gAMPA_' num2str(Poisson_rate_GABAA) 'rGABAA_' ...
%             num2str(gGABAA(o)) 'gGABAA.png'],'-dpng')
%         close all
    end
end

upper_leftAMPA=mean([reshape(PAMPA(1,1,:),1,[]);reshape(PAMPA(1,2,:),1,[]);reshape(PAMPA(2,1,:),1,[]);reshape(PAMPA(2,2,:),1,[])]);
lower_rightAMPA=mean([reshape(PAMPA(9,9,:),1,[]);reshape(PAMPA(9,10,:),1,[]);reshape(PAMPA(10,9,:),1,[]);reshape(PAMPA(10,10,:),1,[])]);;
lower_leftAMPA=mean([reshape(PAMPA(9,1,:),1,[]);reshape(PAMPA(9,2,:),1,[]);reshape(PAMPA(10,1,:),1,[]);reshape(PAMPA(10,2,:),1,[])]);
upper_rightAMPA=mean([reshape(PAMPA(1,9,:),1,[]);reshape(PAMPA(1,10,:),1,[]);reshape(PAMPA(2,9,:),1,[]);reshape(PAMPA(2,10,:),1,[])]);
upper_leftGABAA=mean([reshape(PGABAA(1,1,:),1,[]);reshape(PGABAA(1,2,:),1,[]);reshape(PGABAA(2,1,:),1,[]);reshape(PGABAA(2,2,:),1,[])]);
lower_rightGABAA=mean([reshape(PGABAA(9,9,:),1,[]);reshape(PGABAA(9,10,:),1,[]);reshape(PGABAA(10,9,:),1,[]);reshape(PGABAA(10,10,:),1,[])]);;
lower_leftGABAA=mean([reshape(PGABAA(9,1,:),1,[]);reshape(PGABAA(9,2,:),1,[]);reshape(PGABAA(10,1,:),1,[]);reshape(PGABAA(10,2,:),1,[])]);
upper_rightGABAA=mean([reshape(PGABAA(1,9,:),1,[]);reshape(PGABAA(1,10,:),1,[]);reshape(PGABAA(2,9,:),1,[]);reshape(PGABAA(2,10,:),1,[])]);
upper_left=mean([reshape(P(1,1,:),1,[]);reshape(P(1,2,:),1,[]);reshape(P(2,1,:),1,[]);reshape(P(2,2,:),1,[])]);
lower_right=mean([reshape(P(9,9,:),1,[]);reshape(P(9,10,:),1,[]);reshape(P(10,9,:),1,[]);reshape(P(10,10,:),1,[])]);;
lower_left=mean([reshape(P(9,1,:),1,[]);reshape(P(9,2,:),1,[]);reshape(P(10,1,:),1,[]);reshape(P(10,2,:),1,[])]);
upper_right=mean([reshape(P(1,9,:),1,[]);reshape(P(1,10,:),1,[]);reshape(P(2,9,:),1,[]);reshape(P(2,10,:),1,[])]);

save('EIstats_10Hz.mat','eiratio','f','P','PSDslopes','fitstats')

figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,PSDslopesAMPA)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
title('AMPA only')
figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,PSDslopesGABAA)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
title('GABAA only')
figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,PSDslopes)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')
figure;imagesc(0.00005:0.00005:0.0005,0.00005:0.00005:0.0005,eiratio)
colorbar
xlabel('gGABAA')
ylabel('gAMPA')

figure;loglog(reshape(fAMPA(k,o,:),1,[]),upper_leftAMPA);hold on
loglog(reshape(fAMPA(k,o,:),1,[]),upper_rightAMPA);hold on
loglog(reshape(fAMPA(k,o,:),1,[]),lower_leftAMPA);hold on
loglog(reshape(fAMPA(k,o,:),1,[]),lower_rightAMPA);hold on
legend({'upper left','upper right','lower left','lower right'},'location','southwest')
ylim([1e-9 1e-4])
figure;loglog(reshape(fGABAA(k,o,:),1,[]),upper_leftGABAA);hold on
loglog(reshape(fGABAA(k,o,:),1,[]),upper_rightGABAA);hold on
loglog(reshape(fGABAA(k,o,:),1,[]),lower_leftGABAA);hold on
loglog(reshape(fGABAA(k,o,:),1,[]),lower_rightGABAA);hold on
legend({'upper left','upper right','lower left','lower right'},'location','southwest')
ylim([1e-9 1e-4])
figure;loglog(reshape(f(k,o,:),1,[]),upper_left);hold on
loglog(reshape(f(k,o,:),1,[]),upper_right);hold on
loglog(reshape(f(k,o,:),1,[]),lower_left);hold on
loglog(reshape(f(k,o,:),1,[]),lower_right);hold on
legend({'upper left','upper right','lower left','lower right'},'location','southwest')
ylim([1e-9 1e-4])
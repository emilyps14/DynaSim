clear variables
close all

%% Simulation parameters
dt = 0.01; % ms
sim_length=20000; % [ms]
T = 0:dt:sim_length; % ms
T_PSC = 0:dt:60;

%% Model spec
% Population Firing Rate (E, I) 2 Hz, 5 Hz
% Population Size (E, I) 8000, 2000
% Resting Membrane Potential 65 mV
% Reversal Potential (AMPA, GABAA) 0 mV, 80 mV
% Conductance Rise Time (AMPA, GABAA) 0.1 ms, 0.5 ms
% Conductance Decay Time (AMPA, GABAA) 2 ms, 10 ms
% E:I Ratio 1:2 to 1:6


Poisson_rate_AMPA=8000*2; % [Hz] for all external Poisson input
Poisson_rate_GABAA=2000*5; % [Hz] for all external Poisson input
ERest = 65;
EextAMPA = 0;
EextGABAA = -80;

tau_riseAMPA = 0.1; % ms rise time constant
tau_riseGABAA = 0.5; % ms rise time constant

tauAMPA = 2; % ms decay time constant
tauGABAA = 10; % ms decay time constant

EI_ratios = 1./(1:6);


%% Make PSC timeseries

PSC_E = -exp(-T_PSC./tau_riseAMPA) + exp(-T_PSC./tauAMPA);
PSC_I = -exp(-T_PSC./tau_riseGABAA) + exp(-T_PSC./tauGABAA);

figure(1)
plot(T_PSC,PSC_E,'b',T_PSC,PSC_I,'r')
legend('AMPA PSC','GABAA PSC')
xlabel('Time (ms)')
ylabel('Conductance')

%% Make poisson inputs

spikes_E = double(rand(size(T))<Poisson_rate_AMPA*dt/1000);
spikes_I = double(rand(size(T))<Poisson_rate_GABAA*dt/1000);

%% Convolve PSCs with spike trains

conductance_E = conv(spikes_E,PSC_E,'same');
conductance_I = conv(spikes_I,PSC_I,'same');

figure(2)
plot(T,conductance_E,'b',T,conductance_I,'r')
title('Synaptic conductances')
legend('AMPA','GABAA')
xlabel('Time (ms)')
ylabel('Conductance')

%% Adjust excitation and inhibition balance
adjusted_conductance_I = (1./EI_ratios)'*conductance_I*mean(conductance_E)/mean(conductance_I) ;

figure(3)
subplot(2,1,1)
plot(T,conductance_E)
ylabel('AMPA conductance')
subplot(2,1,2)
plot(T,adjusted_conductance_I)
ylabel('GABA conductance')
legend(cellfun(@num2str,num2cell(EI_ratios),'uniformoutput',false))

%% Compute current
I_E = conductance_E*(ERest-EextAMPA);
I_I = adjusted_conductance_I*(ERest-EextGABAA);

LFP = bsxfun(@plus,I_E,I_I);


sel = 1;
figure(4)
ax(1)=subplot(2,1,1);
plot(T,I_E,'b',T,I_I(sel,:),'r')
legend('AMPA','GABAA')
ylabel('Current')
ax(2)=subplot(2,1,2);
plot(T,LFP(sel,:),'k')
ylabel('LFP Voltage (??)')
xlabel('Time (ms)')
linkaxes(ax,'x')


%% Plot spectra
W = 3;
params.tapers = [ceil(sim_length/1000*W) ceil(min(2*sim_length/1000*W-1,20))]; % change 20 to something smaller to make it run faster, less smooth
params.Fs = 1/dt*1000;
params.fpass = [];


[f,P_E] = power_spectrum(I_E',params);
[~,P_I] = power_spectrum(I_I',params);
[~,P_LFP] = power_spectrum(LFP',params);

sel = 1;
figure(5)
loglog(f,P_E,'b',f,P_I(:,sel),'r',f,P_LFP(:,sel),'k')

%% Figure 1 C and D: current is matched between E and I
I_I_rescaled = I_I(1,:)*mean(I_E)/mean(I_I(1,:));
[~,P_I_rescaled] = power_spectrum(I_I_rescaled',params);

LFP_rescaled = I_E+I_I_rescaled;
[~,P_LFP_rescaled] = power_spectrum(LFP_rescaled',params);

figure(6)
set(6,'position',[440   478   843   320])
ax(1)=subplot(2,2,1);
plot(T,I_E,'b',T,I_I_rescaled,'r')
legend('AMPA','GABAA')
ylabel('Current')
ax(2)=subplot(2,2,3);
plot(T,LFP_rescaled,'k')
ylabel('LFP Voltage (??)')
xlabel('Time (ms)')
linkaxes(ax,'x')
xlim([1000 1200])
subplot(2,2,[2 4])
loglog(f,P_E,'b',f,P_I_rescaled,'r',f,P_LFP_rescaled,'k')
xlim([0 150])
legend('AMPA','GABA','LFP')

%% Figure 1E, F
regression_indices = f>30 & f<50;

for i=1:length(EI_ratios)
    fitstatsLFP(i)=regstats(log10(P_LFP(regression_indices,i)'),log10(f(regression_indices)),'linear',{'yhat','rsquare','beta'}); %f(k,o,1050:end) ~ 30-50 Hz
end

figure(7),clf
subplot(1,2,1)
loglog(f,P_LFP(:,2),'g',f,P_LFP(:,end),'m')
hold on
loglog(f(regression_indices),10.^fitstatsLFP(2).yhat,'k','linewidth',2)
loglog(f(regression_indices),10.^fitstatsLFP(end).yhat,'k','linewidth',2)
hold off
text(mean(f(regression_indices)),10.^(mean(fitstatsLFP(2).yhat)),['Slope: ' num2str(fitstatsLFP(2).beta(2))])
text(mean(f(regression_indices)),10.^(mean(fitstatsLFP(end).yhat)),['Slope: ' num2str(fitstatsLFP(end).beta(2))])
xlim([0 150])
legend(['g_E:g_I = ' num2str(EI_ratios(2))],['g_E:g_I = ' num2str(EI_ratios(end))],'location','southwest')
xlabel('Frequency')
ylabel('Power')

betas = [fitstatsLFP(:).beta];
subplot(1,2,2)
plot(EI_ratios(2:end),betas(2,2:end),'k.-')
xlabel('E:I ratio')
ylabel('Slope (30-50 Hz)')

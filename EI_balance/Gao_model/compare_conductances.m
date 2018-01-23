clear variables
close all

%% Simulation parameters
dt = 0.01; % ms
sim_length=20000; % [ms]
T = 0:dt:sim_length; % ms
T_PSC = 0:dt:60;

W = 3;
params.tapers = [ceil(sim_length/1000*W) ceil(min(2*sim_length/1000*W-1,20))]; % change 20 to something smaller to make it run faster, less smooth
params.Fs = 1/dt*1000;
params.fpass = [];

%% Model spec

% AMPA Parameters
% Poisson_rate=8000*2; % [Hz] for all external Poisson input
% tau_rise = 0.1; % ms rise time constant
% tau = 2; % ms decay time constant

% GABAA Parameters
Poisson_rate=2000*5; % [Hz] for all external Poisson input
tau_rise = 0.5; % ms rise time constant
tau = 10; % ms decay time constant

%% DynaSim Conductance
baseline=0;     % Hz, baseline rate
ac=0;           % Hz, oscillatory component of the signal
freq=0;            % Hz, modulation frequency of the signal
phase=0;          % radians, phase at which the signal begins
onset=0;        % ms, start time of signal
offset=inf;     % ms, stop time of signal

s_dynasim=getPoissonGating(baseline,Poisson_rate,ac,freq,phase,onset,offset,tau,T);
[f,P_dynasim] = power_spectrum(s_dynasim,params);

%% Gao Conductance

PSC = -exp(-T_PSC./tau_rise) + exp(-T_PSC./tau);
spikes = double(rand(size(T))<Poisson_rate*dt/1000);
s_gao = conv(spikes,PSC,'same');
[f2,P_gao] = power_spectrum(s_gao',params);

PSC_instRise = exp(-T_PSC./tau);
s_instRise = conv(spikes,PSC_instRise,'same');
[f3,P_instRise] = power_spectrum(s_instRise',params);

%% Plot spectra

figure(1)
subplot(2,1,1)
plot(T,s_dynasim,'k',T,s_gao,'r',T,s_instRise,'b')
xlim([1000 1200])
xlabel('Time(ms)')
ylabel('Conductance')
legend('DynaSim','Gao','Inst. Rise')
subplot(2,1,2)
loglog(f,P_dynasim,'k',f3,P_gao,'r',f3,P_instRise)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
legend('DynaSim','Gao','Inst. Rise')

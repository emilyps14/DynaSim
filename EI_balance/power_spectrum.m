function [f,P12]=power_spectrum(signal,params)
% Signal should be t x n 

if nargin<2,
    dt=0.00001;
    SR=1/dt;
    L = length(signal);

    T = L*dt; % duration of signal in S
    W = 1; % half-bandwith in Hz

    params.tapers = [ceil(T*W) ceil(min(2*T*W-1,8))];
    params.Fs = SR;
    params.fpass = [0 150];
end

[P12,f] = mtspectrumc(bsxfun(@minus,signal,mean(signal,1)),params);
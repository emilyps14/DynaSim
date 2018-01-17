function [f,P12]=power_spectrum_old(signal)

dt=0.00001;
SR=1/dt;
L = length(signal);
t = (0:L)*dt;
Y = fft(signal-mean(signal));
P2 = abs(Y/L);
P1 = P2(1:L/2+1); % fft returns a mirror image, so cut it in half
P1(2:end-1) = 2*P1(2:end-1); % since you cut off half of the mirror image, double it? Also get rid of DC and Nyquist
f = SR*(0:(L/2))/L;
P12 = P1.^2;
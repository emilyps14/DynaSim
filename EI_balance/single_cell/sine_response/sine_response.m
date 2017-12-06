eqns='dv/dt=@current; {iNa,iK,iSine}; sineA=0.00001; sinef=0.01; sinephi=0; sineE=0; monitor iSine.functions';
data=dsSimulate(eqns,'tspan',[0 5000]);

dsPlot(data);

[f,P]=power_spectrum(data.pop1_iSine_Isine(50001:end));

figure;plot(f,P)


% eqns='dv/dt=Iapp+@current+A*(1+sin(2*pi*f*t/1e3+phi))/2; {iNa,iK}';
% data=dsSimulate(eqns,'tspan',[0 5000],'vary',{'Iapp',0;'A',0.1;'f',10;'phi',0});
% 
% dsPlot(data);
% 
% [f,P]=power_spectrum(data.pop1_v(50001:end));
% 
% figure;plot(f,P)
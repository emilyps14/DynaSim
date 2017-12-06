eqns={'dv/dt=Iapp+@current; {iNa,iK,iPoissonAMPA,iPoissonGABAA};'
    'Iapp=0;'
    'gNa=120;'
    'gK=36;'
    'noise=0;'
    'DCAMPA=16000;'
    'gextAMPA=0.0005'
    'EextAMPA=0;'
    'DCGABAA=10000;'
    'gextGABAA=0.0005;'
    'EextGABAA=-80'
    'monitor iNa.functions, iK.functions, iPoissonAMPA.functions, iPoissonGABAA.functions'
    };
data=dsSimulate(eqns,'tspan',[0 5000]);

dsPlot(data);

[f,P]=power_spectrum(data.pop1_iPoissonAMPA_IPoissonAMPA(50001:end,:)+data.pop1_iPoissonGABAA_IPoissonGABAA(50001:end));

figure;plot(f,P)


% eqns='dv/dt=Iapp+@current+A*(1+sin(2*pi*f*t/1e3+phi))/2; {iNa,iK}';
% data=dsSimulate(eqns,'tspan',[0 5000],'vary',{'Iapp',0;'A',0.1;'f',10;'phi',0});
% 
% dsPlot(data);
% 
% [f,P]=power_spectrum(data.pop1_v(50001:end));
% 
% figure;plot(f,P)
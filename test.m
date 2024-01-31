Fs = 2e7;
Ts = 1/Fs;
Fc = 1e4;
N = 5e4;
t = (0:Ts:(N-1)/Fs);
arb = sin(2*pi*Fc*t);
% arb = sawtooth(2*pi*Fc*t);
% tc = gauspuls("cutoff",Fc,0.6,[],-40);
% t1 = -tc:1/Fs:tc;
% arb = gauspuls(t1,Fc,0.6);
% D = [0 : 1/1e3 : 10e-3 ; 0.8.^(0:10)]';
% arb = pulstran(t,D,@gauspuls,Fc,.5);
plot(t,arb);

arbTo33xxx(1,'10.113.216.140',arb,1,1,0.5,Fs,'Testwave');
% TCP connect; Ip:10.113.216.140; arb wave; channel 1; amp = 1;
% offset = 0.5;Fs = Fs; wavename = 'Testwave'
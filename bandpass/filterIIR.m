%% Filter Design : Bandpass IIR Filter 

samplingFrequency = 10^4;
passBandTolerance = 0.15;
stopBandTolerance = 0.15;

passBandlowerEdge  = 13.6;
passBandHigherEdge = 23.6;

% Analog Values 
p1 = passBandlowerEdge * 1000.0; 
p2 = passBandHigherEdge * 1000.0; 
s1 = (passBandlowerEdge - 1) * 1000.0; 
s2 = (passBandHigherEdge - 1) * 1000.0;

analogFreq  = [s1,p1,p2,s2];
digitalFreq = (analogFreq/samplingFrequency) * 2 * pi;

equiAnalogFreq = tan(digitalFreq/2);
z_s = equiAnalogFreq(2) * equiAnalogFreq(3);
f_B = equiAnalogFreq(3) - equiAnalogFreq(2);

equiAnalogLowPassFreq = zeros(size(equiAnalogFreq));
for i=1:size(equiAnalogFreq)
	equiAnalogLowPassFreq(i) = ((equiAnalogFreq(i)^2)-z_s)/(f_B*equiAnalogFreq(i));
end
D_1 = (1/(1-passBandTolerance)^2)-1;
D_2 = (1/stopBandTolerance.^2)-1;

epsilon = sqrt(D_1);

absEquiAnalogLowPassFreq = abs(equiAnalogLowPassFreq);
stringent_s = min(absEquiAnalogLowPassFreq(1),absEquiAnalogLowPassFreq(4));

N_1 = acosh(sqrt(D_2)/sqrt(D_1)) / acosh(stringent_s / equiAnalogLowPassFreq(3));
N = ceil(N_1);

omega_p = equiAnalogLowPassFreq(3);

poles_a = zeros(2*N-1);
A_k = zeros(2*N);
for k=0:int(2*N)
	A_k = double((2*k+1)*pi/(2*N));
end
B = asinh(1/epsilon)/N;
poles_real_a = omega_p*sin(A_k)*sinh(B);
poles_img_a  = omega_p*cos(A_k)*cosh(B);
poles_a = poles_real_a + 1i*poles_img_a;

a = 1 + 1i;
K_cheby=1;

for i=1:size(poles_a)
  if(real(poles_a(i))< 0)
    a = poly1d('Coefficients',[1,-poles_a(i)])*a;
  end
end

for i=1:size(poles_a)
  if(real(poles_a(i))< 0)
    a = poly1d('Coefficients',[1,-poles_a(i)])*a;
  end
end

for k=1:int(N)
    K_cheby = K_cheby*poles_a(k);
end

numer = real(K_cheby);
denom = 1+0.j

for i=1:size(poles_a)
  if(real(poles_a(i))< 0)
    numer = poly1d('Coefficients',[f_B,0])*numer;
    denom = poly1d('Coefficients',[1,-f_B*poles_a(i),omega_z_s])*denom;
  end
end

[z,p,k] = tf2zpk(numer,denom);

figure;
plot(real(p),imag(p));
plot(real(z),imag(z));
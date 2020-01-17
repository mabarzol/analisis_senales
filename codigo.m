%------------------------------------------------------------------------
%Borramos todas las variables del workspace asi como cualquier ventana
%abierta del mismo para evitar inconvenientes en la gráficación
%------------------------------------------------------------------------
clc;
clear all;
close all;
[s1 fs1] = audioread('audio1.wav');
[s2 fs2] = audioread('audio2.wav');
%------------------------------------------------------------------------
%Las frecuencias de muestreo de los dos audios originales es diferente,
%el audio1 tiene una frecuencia de 16MHz y el audio2 de 48MHz.
%en este caso dejaremos ambos audios a una frecuencia de muestreo igual 
%a 16MHz se divide para 3 la frecuencia de muestreo del audio2 y se tomará
%en cuenta cada 3 muestras del audio para dejar en las mismas condiciones 
%ambos audios asi como su frecuencia de corte
%------------------------------------------------------------------------
l = s2(:,1);
r = s2(:,2);
l = l(1:3:end);
r = r(1:3:end);
s2 = [l r];
fs2=fs2/3;
fs = fs1; %fs1 y fs2 son iguales
%-------------------------------------------------------------------------
%Graficamos las dos señales originales (TIEMPO Y FRECUENCIA)
%-------------------------------------------------------------------------
figure(1)
subplot(221)
T=length(s1)/fs;
t=linspace(0,T,T*fs);
plot(t,s1);
grid on;
title('Audio1.wav Original')    % Título
xlabel('Tiempo (s)')            % Etiqueta del eje X
ylabel('Amplitud (V)')          % Etiqueta del eje Y

subplot(222)
T=length(s2)/fs;
t=linspace(0,T,T*fs);
plot(t,s2);
grid on;
title('Audio2.wav Original')    % Título
xlabel('Tiempo (s)')            % Etiqueta del eje X
ylabel('Amplitud (V)')          % Etiqueta del eje Y

subplot(223)
fft_signal(s1,fs);title('Espectro de Frecuencia de Audio1.wav Original')
xlabel('Frecuencia (Hz)');
xlim([0 4e3])

subplot(224)
fft_signal(s2,fs);title('Espectro de Frecuencia de Audio2.wav Original')
xlabel('Frecuencia (Hz)');
xlim([0 4e3])
%------------------------------------------------------------------------
%Sumamos ambas señales haciendo que ambos audios tengan el mismo tamaño de
%muestreo y evitar errores por matrices de diferente tamaño.
%------------------------------------------------------------------------
A1 = length(s1)-length(s2);
B1 = length(s2)-length(s1);
s1 = vertcat(s1,zeros(B1,2));
s2 = vertcat(s2,zeros(A1,2));
suma=s1+s2;
%------------------------------------------------------------------------
%Gráfico de la suma de señales (TIEMPO Y FRECUENCIA)
%------------------------------------------------------------------------
figure(2)
subplot(211)
T=length(suma)/fs;
t=linspace(0,T,T*fs);
plot(t,suma);
grid on;
title('Suma de los Audios')% Título
xlabel('Tiempo (s)')         % Etiqueta del eje X
ylabel('Amplitud (V)')      % Etiqueta del eje Y

subplot(212)
fft_signal(suma,fs);title('Espectro de Frecuencia de la Suma')
xlim([0 4e3])
%------------------------------------------------------------------------
%Según el analisis del gráfico de la densidad espectral del audio1.wav
%reconstruiremos el audio haciendo pasar la suma a travez de un filto paso
%bajo con frecuencia de corte de 150 Hz y un filtro paso alto con
%frecuencia de corte de 1KHz
%------------------------------------------------------------------------
fNorm = 150 / (fs/2);
[b,a] = butter(10, fNorm, 'low'); 
audio_filtrado1 = filtfilt(b, a, suma);   
fNorm = 1000 / (fs/2);
[b2,a2] = butter(10, fNorm, 'high');
audio_filtrado1 = audio_filtrado1 + filtfilt(b2, a2, suma);
%------------------------------------------------------------------------
%Según el analisis del gráfico de la densidad espectral del audio1.wav
%reconstruiremos el audio haciendo restando la suma de los audios sin
%filtrar con el audio1 filtrado para obtener el complemento de la grafica
%que contiene la información del audio2, luego le restaremos un
%filtro pasa banda entre 220.1 Hz a 485.7 Hz, y finalmente agregaremos
%mayor detalle con un filtro paso bajo con frecuencia de corte de 190 Hz
%------------------------------------------------------------------------
audio_filtrado2 = suma - audio_filtrado1;
Wp = [220.1 460.7]/(fs/2); Ws = [210 470]/(fs/2);
Rp = 3; Rs = 10; 
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b3,a3] = butter(n,Wn);       
audio_filtrado2 = audio_filtrado2 - filtfilt(b3, a3, audio_filtrado2);
fNorm = 180 / (fs/2);
[b4,a4] = butter(10, fNorm, 'low'); 
audio_filtrado2 = audio_filtrado2 + filtfilt(b4, a4, suma);
%------------------------------------------------------------------------
%Gráficamos el filtro paso bajo que hemos hecho
%------------------------------------------------------------------------
[H,w]=freqz(b,a,512,fs);
figure(3)
subplot(221)
plot(w,abs(H));
grid on;
title ('Paso Bajo audio1');
xlabel('Frecuencia (Hz)');
ylabel('H(f) db')
xlim([0 5e3])

[H,w]=freqz(b2,a2,512,fs);
subplot(222)
plot(w,abs(H));
grid on;
title ('Paso alto audio1');
xlabel('Frecuencia (Hz)')
ylabel('ángulo de H rad')
xlim([0 5e3])

[H,w]=freqz(b3,a3,512,fs);
subplot(223)
plot(w,abs(H));
grid on;
title ('Paso banda audio2');
xlabel('Frecuencia (Hz)')
ylabel('ángulo de H rad')
xlim([0 5e3])

[H,w]=freqz(b4,a4,512,fs);
subplot(224)
plot(w,abs(H));
grid on;
title ('Paso bajo audio2');
xlabel('Frecuencia (Hz)')
ylabel('ángulo de H rad')
xlim([0 5e3])
%------------------------------------------------------------------------
%Gráfico del audio filtrado 1 y 2 en el dominio del tiempo y frecuencia
%------------------------------------------------------------------------
figure(4)
subplot(221)
T=length(suma)/fs;
t=linspace(0,T,T*fs);
plot(t,audio_filtrado1);
grid on;
title('audio1 filtrado')% Título
xlabel('Tiempo (s)')         % Etiqueta del eje X
ylabel('Amplitud (V)')      % Etiqueta del eje Y


subplot(222)
T=length(suma)/fs;
t=linspace(0,T,T*fs);
plot(t,audio_filtrado2);
grid on;
title('audio2 filtrado')% Título
xlabel('Tiempo (s)')         % Etiqueta del eje X
ylabel('Amplitud (V)')      % Etiqueta del eje Y

subplot(223)
fft_signal(audio_filtrado1,fs);title('Espectro de Frecuencia audio1 filtrado')
xlim([0 4e3])

subplot(224)
fft_signal(audio_filtrado2,fs);title('Espectro de Frecuencia audio2 filtrado')
xlim([0 4e3])
%-------------------------------------------------
%Guardado de archivos de audio recuperado
%-------------------------------------------------
audiowrite('audio_filtrado1.wav',audio_filtrado1.*8,fs);
audiowrite('audio_filtrado2.wav',audio_filtrado2.*8,fs);



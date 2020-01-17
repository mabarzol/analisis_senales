function f=fft_signal(y,Fs)
L=length(y); % Longitud de la señal
NFFT = 2^nextpow2(L); % Siguiente potencia de 2 de la long de y
Y = fft(y,NFFT)/L; % FFT de la señal
f = Fs/2*linspace(0,1,NFFT/2+1); % Rango de frecuencia
% Plot single-sided amplitude spectrum.
% subplot(313)
plot(f,2*abs(Y(1:NFFT/2+1))) 
grid on;
xlabel('Frecuencia (Hz)')
ylabel('|Y(f)|')
end

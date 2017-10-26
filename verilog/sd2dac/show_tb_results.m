%
% Show testbench results for sd2dac
% 
% This is a MATLAB file
%

fileID = fopen('bin/dacout.sw');
A = fread(fileID,'*int32')';
fclose(fileID);

A = single(A)/2^31;

clf;
figure(1);
X = fft(A.*blackman(length(A))') / (length(A)/4);
semilogx(20*log10(abs(X)));
grid on;
axis([0 length(X)/2 -140 10]);


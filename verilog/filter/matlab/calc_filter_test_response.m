%
% Calculate filter test response
%

% the 12-pole filter has the following hex values
% in 10-bit sign-magnitude format:
%
%
% // section 1
% coef_in     = 10'h3C9;
% coef_in     = 10'h1E4;
% 
% // section 2
% coef_in     = 10'h2B8;
% coef_in     = 10'h1CF;
% 
% // section 3
% coef_in     = 10'h238;
% coef_in     = 10'h080;
% 
% // section 4
% coef_in     = 10'h195;
% coef_in     = 10'h1BF;
% 
% // section 5
% coef_in     = 10'h135;
% coef_in     = 10'h1BF;
% 
% // section 6
% coef_in     = 10'h000;
% coef_in     = 10'h000;

A1 = [1 -2*hex2dec('1C9')/512 hex2dec('1E4')/512];
A2 = [1 -2*hex2dec('0B8')/512 hex2dec('1CF')/512];
A3 = [1 -2*hex2dec('038')/512 hex2dec('080')/512];
A4 = [1 2*hex2dec('195')/512 hex2dec('1BF')/512];
A5 = [1 2*hex2dec('135')/512 hex2dec('1BF')/512];
A6 = [1 2*hex2dec('000')/512 hex2dec('000')/512];

A = conv(A1,conv(A2,conv(A3,conv(A4,conv(A5,A6)))));
figure(1);
[H,W] = freqz(1,A,4096,10000);
plot(W,20*log10(abs(H)));
title('Frequency response of EH allophone');
xlabel('Frequency (Hz)');
ylabel('Magnitude (db)');
grid on;

% get step response to an input of 16
x = ones(1,32)*16;
y = filter(1,A,x);
figure(2);
plot(y);
title('Impulse step to [16 16 16 16 16 16 ...]');
xlabel('Samples');
ylabel('Output');
grid on;

state1 = 0;
state2 = 0;
in = 16;
for I=1:10,
    accu = in-A1(2)*state1-A1(3)*state2;
    state2 = state1;
    state1 = accu;
    fprintf(1,'%f %f %f\n', accu, state1, state2);
end;


%// SPEECH 256
%// Copyright (C) 2017 Niels Moseley / Moseley Instruments
%// http://www.moseleyinstruments.com
%//
%// This program is free software: you can redistribute it and/or modify
%// it under the terms of the GNU General Public License as published by
%// the Free Software Foundation, either version 3 of the License, or
%// (at your option) any later version.
%//
%// This program is distributed in the hope that it will be useful,
%// but WITHOUT ANY WARRANTY; without even the implied warranty of
%// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%// GNU General Public License for more details.
%//
%// You should have received a copy of the GNU General Public License
%// along with this program.  If not, see <http://www.gnu.org/licenses/>.
%//
%//
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


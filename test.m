clear all;
close all;

Kp = 1;
Ki = 1.5;
Kd = 0.6;
Bias = 150;
SetPoint = 10;

t = tcpip('192.168.1.8',58887);
set(t,'ByteOrder','littleEndian')
fopen(t);

fwrite(t,[Kp Ki Kd Bias SetPoint],'float32');

fwrite(t,[13,10])
fclose(t);  
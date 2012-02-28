clear all;
close all;

Kp = 3.345;
Ki = 1.5;
Kd = 0.6;
Bias = 200.0;

t = tcpip('127.0.0.1',58887);
set(t,'ByteOrder','littleEndian')
fopen(t);

fwrite(t,[Kp Ki Kd Bias],'float32');

fwrite(t,[13,10])
fclose(t);  
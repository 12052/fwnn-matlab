function w = wavelet( x, a, b )
%WAVELET ����
%ī����ñ��С������
%a����Ϊ0
z = (x - b) / a;
z = z^2; % ���к���һ��ʹ��z����ʾz^2
w = (1 - z) * exp(-z/2) / sqrt( abs(a) ); % ʹ��z����ʾz^2
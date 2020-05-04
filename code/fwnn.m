%FWNN �ű��ļ�����Ϊ������ʹ��
% ������
close all
clear
% �ؼ�����
d = 5; % ��������Ŀ��
m = d; % �����źŵĸ���
n = 5; % ��ϵ�����ĸ�����ģ���жϵĸ�����С�������ĸ���
epoch = 2000; % ��������
num_yangben = 49; % ���ݸ���
num_test = 12;
rate = 0.08; % ѧϰ����
mom = 0.5; % ���� 

% ������������
data = indata();
%result = plant(data);
result = data(:,d+1);
% TEST
file_yangben = '���Լ�.dat';
fid = fopen(file_yangben);
%u = fread(fid,[size_input_x,size_input_y],'float');
u_test = dlmread(file_yangben,',');
fclose(fid);

% �����ʼ�����������ڣ�0��1��
c = rand(m, n);
q = rand(m, n); % ע�⣺����Ϊ��
a = rand(n, m);
b = rand(n, m);
w = rand(1, n);

% t-1�����Ĳ���ֵ
pc = c;
pq = q;
pa = a;
pb = b;
pw = w;

% t+1�����Ĳ���ֵ
nc = zeros(m, n);
nq = zeros(m, n);
na = zeros(n, m);
nb = zeros(n, m);
nw = zeros(1, n);

% ���ڻ�ͼ������
tu = zeros(epoch, num_yangben);
E = zeros(epoch, num_yangben);

% ѵ������
tic % ��ʼ��ʱ
for loop1 = 1 : 1 : epoch
    for loop2 = 1 : 1 : num_yangben
        % ��ʼ���м�����
        x = zeros(1, m);
        g = zeros(m, n);
        U = zeros(1, n);
        p = zeros(1, n);
        W = zeros(1, n);
        %y = zeros(1, n);
        % ������ڵ㸳ֵ
        for i = 1 : 1 : d
            x(i) = data(loop2,i);
        end
        %for i = 1 : 1 : d
           % x(m + 1 - i) = result(loop2 - i);
        %end
        % ����ڶ���ڵ�����ֵ
        for i = 1 : 1 : m
            for j = 1 : 1 : n
                g(i, j) = relation(x(i), c(i, j), q(i, j));
            end
        end
        % ���������ڵ�������ͬʱ��¼������ڵ��ѡ����Ϣ
        for i = 1 : 1 : n
            [min, which] = fuzzy(g, m, i);
            U(i) = min;
            p(i) = which;
        end
        % ������Ĳ�ڵ�����
        for i = 1 : 1 : n
            for j = 1 : 1 : m
                W(i) = W(i) + wavelet(x(j), a(i, j), b(i, j));
            end
        end
        y = w .* W;
        % �������յ����
        u = defuzz(U, y, n);
        tu(loop1, loop2) = u;
        % �������
        temp1 = u - result(loop2);
        E(loop1, loop2) = temp1^2 / 2;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % ����ʹ���ݶ��½��㷨��������
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % ����E��w��ƫ����
        temp2 = sigamau(U, n);
        Etow = zeros(1, n);
        sima = zeros(1, n);
        for i = 1 : 1 : n
            Etow(i) = temp1 * U(i) * W(i) / temp2;
            sima(i) = temp1 * U(i) * w(i) / temp2;
        end
        % ���㼸��������ظ�ʹ�õ�����
        temp3 = zeros(n, m);
        temp4 = zeros(n, m);
        for i = 1 : 1 : n
            for j = 1 : 1 : m
                temp3(i, j) = varz2(x(j), a(i, j), b(i, j)); % temp3= z^2
                temp4(i, j) = exp(-temp3(i, j)/2) / sqrt(abs(a(i, j))^3); % temp4 = ?
            end
        end
        % ����E��a��ƫ����
        Etoa = zeros(n, m);
        for i = 1 : 1 : n
            for j = 1 : 1 : m
                temp5 = temp3(i, j); % temp5 = z^2
                Etoa(i, j) = sima(i) * (3.5 * temp5 - temp5^2 - 0.5) * temp4(i , j);
            end
        end
        % ����E��b��ƫ����
        Etob = zeros(n, m);
        for i = 1 : 1 : n
            for j = 1 : 1 : m
                temp5 = temp3(i, j); % temp5 = z^2
                Etob(i, j) = sima(i) * (3 * temp5 - temp5^3) * temp4(i , j);
            end
        end
        % ����E��c��q��ƫ����
        utoU = zeros(1, n);
        for i = 1 : 1 : n
            utoU(i) = (y(i) - u) / temp2; % temp2 = sigama(U)
        end
        [Utoc, Utoq] = Utocq(g, x, c, q, m, n, p);
        Etoc = zeros(m, n);
        Etoq = zeros(m, n);
        for i = 1 : 1 : m
            for j = 1 : 1 : n
                temp6 = temp1 * utoU(j);
                Etoc(i, j) = temp6 * Utoc(i, j);
                Etoq(i, j) = temp6 * Utoq(i, j);
            end
        end
        % �Բ�������
        nw = w - rate * Etow + mom * (w - pw);
        na = a - rate * Etoa + mom * (a - pa);
        nb = b - rate * Etob + mom * (b - pb);
        nc = c - rate * Etoc;
        nq = q - rate * Etoq;
        % �޸Ĳ���t-1��t
        pw = w; w = nw;
        pa = a; a = na;
        pb = b; b = nb;
        c = nc;
        q = nq;
    end
end
toc % ������ʱ������ʾʱ��
figure(1)
% ͼ����ʾͳ����Ϣ
k = 1 : 1 : num_yangben;
ttu = tu(epoch, :);
plot(k, result, '-', k, ttu, '-r')
legend('���������', '������Ԥ��ֵ')
title('ѵ�����');
xlabel('����');
ylabel('���ȼ�');
%%============================================================'
%%����
%%===========================================================
for loop2 = 1 : 1 : num_test
        % ��ʼ���м�����
        x = zeros(1, m);
        g = zeros(m, n);
        U = zeros(1, n);
        p = zeros(1, n);
        W = zeros(1, n);
        %y = zeros(1, n);
        % ������ڵ㸳ֵ
        for i = 1 : 1 : d
            x(i) = u_test(loop2,i);
        end
        %for i = 1 : 1 : d
           % x(m + 1 - i) = result(loop2 - i);
        %end
        % ����ڶ���ڵ�����ֵ
        for i = 1 : 1 : m
            for j = 1 : 1 : n
                g(i, j) = relation(x(i), c(i, j), q(i, j));
            end
        end
        % ���������ڵ�������ͬʱ��¼������ڵ��ѡ����Ϣ
        for i = 1 : 1 : n
            [min, which] = fuzzy(g, m, i);
            U(i) = min;
            p(i) = which;
        end
        % ������Ĳ�ڵ�����
        for i = 1 : 1 : n
            for j = 1 : 1 : m
                W(i) = W(i) + wavelet(x(j), a(i, j), b(i, j));
            end
        end
        y = w .* W;
        % �������յ����
        result_test(loop2) = defuzz(U, y, n);
end
figure(2)
% ͼ����ʾ������Ϣ
k = 1 : 1 : num_test;
plot(k, u_test(:,6), 'g',k, result_test, 'r')
legend('���Լ����', '���Լ�Ԥ��ֵ')
title('���Խ��');
xlabel('����');
ylabel('���ȼ�');

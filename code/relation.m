function g = relation( x, c, q )
%RELATION ����
%��ϵ�����Ǹ�˹������

g = exp(- ((x-c) / q)^2);
% ��֤������0�����
if g < 1.0e-004
    g = 1.0e-004;
end

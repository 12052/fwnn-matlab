%����Сֵ
function [ min, which ] = fuzzy( g, m, n )
%FUZZY ����

min = g(1, n);
which = 1;
for i = 2 : 1 : m
    if min > g(i, n)
        min = g(i, n);
        which = i;
    end
end

function u = indata( )
%INPUT ����

file_yangben = '������.dat';
fid = fopen(file_yangben);
%u = fread(fid,[size_input_x,size_input_y],'float');
u = dlmread(file_yangben,',');
fclose(fid);


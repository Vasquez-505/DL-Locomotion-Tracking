function [] = filename_compiler_v2(path)
%filename_compiler_v2 lists files in specified directory
%   Directory previously chosen through the "File" menu in the GUI

list=dir(path);
length = size(list,1);
final = cell(length,1);

for i = 3:length
    directory = list(i).folder;
    name = list(i).name;
    filename = strcat(directory,'\',name);
    final{i}=filename;
end

matrix = vec2mat(final,1);

fileID=fopen(strcat(path,'\file.txt'),'w');
fileID_dummy=fopen('file.txt','w');
formatSpec='%s\n';

[nrows,ncols] = size(final);

for row = 1:nrows
    fprintf(fileID,formatSpec,final{row,:});
    fprintf(fileID_dummy,formatSpec,final{row,:});
end

fclose(fileID);
fclose(fileID_dummy);

end


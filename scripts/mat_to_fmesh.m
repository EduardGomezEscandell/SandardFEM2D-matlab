%% Data entry
project_name = 'test';

%% Opening files
load('meshHW1c.mat')

file_msh = fopen(['../data/',project_name,'/mesh.msh'],'w+');
file_bc = fopen(['../data/',project_name,'/boundaries.txt'],'w+');

fprintf(file_msh,'MESH dimension 2 ElemType Triangle Nnode 3\n');

%% Creating GiD mesh file
fprintf(file_msh,'Coordinates\n');
for i=1:length(X)
    fprintf(file_msh,'%5d %15g %15g %15g\n',i,X(i,1),X(i,2),0);
end
fprintf(file_msh,'End Coordinates\n\n');

fprintf(file_msh,'Elements\n');
for i=1:length(T)
    fprintf(file_msh,'%d %d %d %d\n',i,T(i,1),T(i,2),T(i,3));
end
fprintf(file_msh,'End Elements\n');

%% Upgrading to .fmsh
try
    msg = system(['python fix_mesh.py ',project_name]);
catch
    error('Failed to transform from .msh to .fmsh succesfully');
end

fclose(file_msh);

%% Creating boundaries file

fprintf(file_bc,'Dirichlet\n');
for i=1:length(inflowEdges)
    fprintf(file_bc,'%6d %12e\n',inflowEdges(i,1),0);
end
fprintf(file_bc,'%6d %12e\n',inflowEdges(i,2),0);
for i=1:length(outflowEdges)
    fprintf(file_bc,'%6d %12e\n',outflowEdges(i,1),1);
end
fprintf(file_bc,'%6d %12e\n',outflowEdges(i,2),1);
fprintf(file_bc,'End Dirichlet\n\n');

fprintf(file_bc,'Neumann\n');
fprintf(file_bc,'End Neumann\n');

fclose(file_bc);
clc; clear;
figure();
addpath('subroutines')
addpath('subroutines/imported')
addpath('classes')

% Data entry
project_dir = 'data/square_T6';

% Loading geometry
domain = Domain();
domain.read_from_file(project_dir);
domain.problem_type = -1; % Thermal

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

% Assembling system
seq = SystemOfEquations(domain);
seq.assemble(domain, gauss_data);

% Solving
seq.solve()
seq.clean_solution(domain)

% Post-processing
exageration = 1;
seq.plot_result(domain, exageration);
seq.export_to_vtk(domain, project_dir);
clc; clear;
addpath('subroutines')
addpath('subroutines/imported')
addpath('classes')

% Data entry
project_dir = 'data/square_T6';

% Loading geometry
domain = Domain();
domain.read_from_file(project_dir);
domain.problem_type = -2; % Aeropotential

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

% Assembling system
seq = SystemOfEquations(domain);
seq.assemble(domain, gauss_data);

% Solving
seq.solve()
seq.clean_solution(domain)
% seq.calc_gradients(domain);

% Post-processing
% subplot(121);
% seq.plot_gradients(domain)
% hold on
% domain.draw_mesh([0.9 0.9 0.9]);
% % 
% subplot(122);
exageration = 1;
seq.plot_result(domain, exageration);
% seq.export_to_vtk(domain, project_dir);
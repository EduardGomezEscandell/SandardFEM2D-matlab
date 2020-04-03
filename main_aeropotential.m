clc; clear;
addpath('subroutines')
addpath('subroutines/imported')
addpath('classes')

% Data entry
project_dir = 'data/constriction_Q9';

% Loading geometry
domain = Domain();
domain.problem_type = -2; % Aeropotential
domain.read_from_file(project_dir);

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

disp('Data loaded. Assembling...')

% Assembling system
seq = SystemOfEquations(domain);
seq.assemble(domain, gauss_data);

disp('Assembly completed. Solving...')

% Solving
seq.solve()
seq.clean_solution(domain)
seq.calc_gradients(domain);
circ = seq.aero_calc_circulation(domain, gauss_data, [1, .5],0.4);
disp('Solved.')

% Post-processing
% Obtaining circulation (Useful to obtain lift)
disp('Total circulation is');
disp(circ);
disp('Drawing...')

% Plot of Mesh and gradients
subplot(121);
domain.draw_mesh([0.9 0.9 0.9]);
hold on
seq.plot_gradients(domain)
title('Velocity field');
hold off

% Plot of mesh and potential field
subplot(122);
exageration = 1;
seq.plot_result(domain, exageration);
title('Potential field');

disp('Drawn. Exporting...');

seq.export_to_vtk(domain, project_dir);

disp('Done');
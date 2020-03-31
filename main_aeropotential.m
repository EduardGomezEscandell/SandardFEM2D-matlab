clc; clear;
addpath('subroutines')
addpath('subroutines/imported')
addpath('classes')

% Data entry
project_dir = 'data/cylinder_Q9';

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

disp('Solved. Drawing...')

% Post-processing
subplot(121);
domain.draw_mesh([0.9 0.9 0.9]);
hold on
seq.plot_gradients(domain)
title('Velocity field');
hold off
 
subplot(122);
exageration = 1;
seq.plot_result(domain, exageration);
title('Potential field');

disp('Drawn. Exporting...');

seq.export_to_vtk(domain, project_dir);

disp('Done');
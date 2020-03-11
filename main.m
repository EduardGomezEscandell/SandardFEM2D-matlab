close all; clc; clear;

% Data entry
project_dir = 'data/square_thin';

% Loading geometry
domain = Domain();
domain.read_from_file(project_dir);

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

% Assembling system
seq = SystemOfEquations(domain);
seq.assemble(domain, gauss_data);
seq.enforce_dirichlet(domain);

% Solving
seq.solve()
seq.clean_solution(domain)

% Post-processing
exageration = 10;
seq.plot_result(domain, exageration);
seq.export_to_vtk(domain, project_dir);
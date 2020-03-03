% Data entry
input_dir = 'data/square_dense';
outputFileName = 'results/square.res';

% Loading geomery
domain = Domain();
domain.readFromFile(input_dir);

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

% Assembling system
seq = SystemOfEquations(domain.n_nodes*domain.DOF_per_node);

% Solving
seq.fake_solution(domain, @solution_fun);

% Post-processing
seq.plotResult(domain);
seq.export_to_vtk(domain, input_dir);

function z = solution_fun(X)
    z(1) = 0.01*sin(3*X(1));
    z(2) = 0.03*X(1);
end
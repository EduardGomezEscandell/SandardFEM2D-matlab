% Data entry
input_dir = 'data/square_dense';
outputFileName = 'results/square.res';

% Loading geomery
dom = Domain();
dom.readFromFile(input_dir);

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

% Assembling system
seq = SystemOfEquations(dom.n_nodes*dom.DOF_per_node);

% Solving
seq.fake_solution(dom, @solution_fun);

% Post-processing
seq.plotResult(dom);
seq.export_to_vtk(dom, input_dir);

function z = solution_fun(X)
    z(1) = 0.01*sin(3*X(1));
    z(2) = 0.03*X(1);
end
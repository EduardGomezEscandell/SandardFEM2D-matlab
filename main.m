% Data entry
inputFileName = 'data/square_dense';
outputFileName = 'results/square.res';

% Loading geomery
dom = Domain();
dom.readFromFile(inputFileName);

% Loading math data
gauss_data = loadGaussData(dom);
calcShapeFunctions(gauss_data, dom);

% Assembling system
seq = SystemOfEquations(dom.n_elems*dom.nodes_per_elem);

% Solving
seq.fake_solution(dom, @solution_fun);

% Post-processing
seq.plotResult(dom);

function z = solution_fun(X)
    z = sin(6*X(1)) + sin(X(2));
end
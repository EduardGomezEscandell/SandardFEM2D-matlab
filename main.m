% Data entry
inputFileName = 'data/square';
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

% Post-processing
% Data entry
inputFileName = 'data/square';
outputFileName = 'results/square.res';

% Loading geomery
dom = Domain();
dom.readFromFile(inputFileName);

% Loading math data
gaussData = loadGaussData(dom);

% Assembling system

% Solving

% Post-processing
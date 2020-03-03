% Data entry
input_dir = 'data/square_dense';

% Loading geomery
domain = Domain();
domain.readFromFile(input_dir);

% Loading math data
gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

% Assembling system
seq = SystemOfEquations(domain.n_nodes*domain.DOF_per_node);

% Solving
seq.fake_solution(domain, @made_up_solution);
seq.isSolved = true;

% Post-processing
exageration = 10;
seq.plot_result(domain, exageration);
seq.export_to_vtk(domain, input_dir, exageration);

% Support function
function z = made_up_solution(X, domain)
    switch domain.n_dimensions
        case 1
            z = 0.03*sin(X(1));
        case 2
            z(1) = 0.02*sin(2*X(1));
            z(2) = 0.03*X(1);
        case 3
            z(1) = 0.02*sin(3*X(1));
            z(2) = 0.03*X(1);
            z(3) = -2*X(2);
    end
end
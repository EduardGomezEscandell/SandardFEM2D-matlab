% This test plots the shape functions. To test, move this file to the main
% directory and run it.

% Settings:
shape_fun = 1;   % Shape function
deg = 1;         % Interpollation degree
elem_type = 'T'; % Element type
gauss_deg = 20;

% Main program
domain = Domain();
domain.n_dimensions = 2;
domain.elem_type = elem_type;
domain.integrationDegree = gauss_deg;
domain.interpolationDegree = deg;
domain.nodes_per_edge = deg + 1;

gauss_data = loadGaussData(domain);
calcShapeFunctions(gauss_data, domain);

switch elem_type
    case 'T'
        corners = [0 0
                   2 5
                   1 7];
        X = [];
        Z = [];
        for gp_cell = gauss_data.tris'
            gp = gp_cell{1};
            X(end+1,:) = gp.Z * corners;
            Z(end+1,:) = gp.N{shape_fun}';
        end
    case 'Q'
        X = [];
        Z = [];
        for gp_cell = gauss_data.quad'
            gp = gp_cell{1};
            X(end+1,:) = gp.Z;
            Z(end+1,:) = gp.N{shape_fun}';
        end
    otherwise
        error('Unknown element type')
end


figure(1)

plot3(X(:,1),X(:,2),Z,'kx');
grid on
xlabel('x')
ylabel('y')
axis equal
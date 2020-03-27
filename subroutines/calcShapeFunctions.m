function calcShapeFunctions(gauss_data, domain)
    % This function is in charge of fillling in the fields .N and .gradN of
    % the gauss points in the cell array gauss_data
    
    switch(domain.n_dimensions)
        case 1
            shape_functions_segment(gauss_data, domain.interpolationDegree);
        case 2
            switch(domain.elem_type)
                case 'T'
                    % 2D triangular elements
                    shape_functions_triangle(gauss_data.plane, domain);
                    shape_functions_segment(gauss_data.line, domain.nodes_per_edge-1);
                case 'Q'
                    % 2D quadrilateral elements
                    shape_functions_quad(gauss_data.plane, domain);
                    shape_functions_segment(gauss_data.line, domain.nodes_per_edge-1);
            end
        case 3
            % Fill in for 3D elements
        otherwise
            error('Only dimensions 1-3 are supported')
    end
end

function shape_functions_segment(gauss_data, interpolation_degree)
    for i = 1:size(gauss_data,1)
        gauss_point = gauss_data{i};
        gauss_point.segment_shape_fun(gauss_point.Z,interpolation_degree);
    end
end

function shape_functions_triangle(gauss_data, domain)
    % Filling the shape function data point by point for traingular 2D
    % elements
    Xelem = [0 0; 1 0; 0 1]; % Isoparametric triangle
    for i = 1:size(gauss_data,1)
        gauss_point = gauss_data{i};
        X = gauss_point.change_coordinates_triangle(Xelem);
        x = X(1);
        y = X(2);
        n = domain.interpolationDegree;
        gauss_point.triangle_shape_fun(x,y,n);
    end
end

function shape_functions_quad(gauss_data, domain)
    % Filling the shape function data point by point for quadrilateral 2D
    % elements
    for i = 1:size(gauss_data,1)
        gauss_point = gauss_data{i};
        % No need to transform coordinates since gauss points are in [-1,1] space
        x = gauss_point.Z(1);
        y = gauss_point.Z(2);
        n = domain.interpolationDegree;
        gauss_point.quad_shape_fun(x,y,n);
    end
end
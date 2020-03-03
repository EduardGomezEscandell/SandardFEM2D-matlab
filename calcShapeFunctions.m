function calcShapeFunctions(gauss_data, domain)
    % This function is in charge of fillling in the fields .N and .gradN of
    % the gauss points in the cell array gauss_data
    
    switch(domain.n_dimensions)
        case 1
            % Fill in for bar element
        case 2
            switch(domain.elem_type)
                case 'T'    % 2D triangular elements
                    shape_functions_triangle(gauss_data, domain);
                case 'Q'    % 2D quadrilateral elements
                    
            end
        case 3
            % Fill in for 3D elements
        otherwise
            error('Only dimensions 1-3 are supported')
    end
end

function shape_functions_triangle(gauss_data, domain)
    % Filling the shape function data point by point for traingular 2D
    % elements
    for i = 1:size(gauss_data,1)
        lagrange_polynomial_triangle(gauss_data{i}, domain)
    end
end


function lagrange_polynomial_triangle(gauss_point, domain)
    Xelem = [0 0; 1 0; 0 1]; % Isoparametric triangle
    X = gauss_point.changeCoords(domain, Xelem);
    x = X(1);
    y = X(2);
    n = domain.interpolationDegree;
    gauss_point.triangle_shape_fun(x,y,n);
end
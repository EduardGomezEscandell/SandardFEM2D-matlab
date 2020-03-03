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
    Xelem = [-1 -1; 1 -1; -1 ,1]; % Isoparametric triangle
    X = gauss_point.changeCoords(domain, Xelem);
    x = X(1);
    y = X(2);
    n = domain.interpolationDegree;
    
    i = 0;
    j = 0;
    for nd = 1:domain.nodes_per_elem
        % Meaning of [i,j]:
        % This indices refer to the shape functions. The shape function
        % i,j is that which is zero in all nodes except for the node
        % with local indices [i,j]. On a sample triangle of
        % interpolation degree of 3, these look like:
        %
        % [3,0]
        % [2,0] [2,1]
        % [1,0] [1,1] [1,2]
        % [0,0] [0,1] [0,2] [0,3]
        %
        % I made them go from 0 to n because the formulas I found work
        % with indices starting at 0
        %
        % This indexing only appears here, nowhere else in the program

        % Shape function
        gauss_point.N{nd} = F(x) * G(x) * H(x,y);

        % Shape function d/dx
        gauss_point.gradN{nd}(1,1) = n*G(y)*(F_x(x)*H(x,y) + F(x)*H_x(x,y));

        % Shape function d/dy
        gauss_point.gradN{nd}(2,1) = n*F(x)*(G_y(y)*H(x,y) + G(y)*H_y(x,y));

        j = j + 1;
        if j>(domain.interpolationDegree - i)
            j = 0;
            i = i+1;
        end
    end
    
    % Building blocks
    function z = F(x)
        z = 1;
        for k = 0:(i-1)
          z = z * ((n*x-k)/(i-k));
        end
    end
    function z = F_x(x)
       z = 0;
       for a=0:(i-1)
           f = 1/(i-a);
           for b=0:(i-1)
                if(b~=a)
                    f = f*(n*x-b)/(i-b);
                end
           end
           z = z + f;
       end 
    end

    function z = G(y)
        z = 1;
        for k= 0:(j-1)
            z = z * ((n*y-k)/(j-k));
        end
    end
    function z = G_y(y)
        z = 0;
        for a = 1:(j-1)
            f = 1/(j-a);
            for b = 0:(j-1)
               if(b ~=a)
                   f = f * (n*y - b)/(j-b);
               end
            end
            z = f + z;
        end
    end
    function z = H(x,y)
        z = 1;
        for k= (i+j+1):n
            z = z * ((n*(x+y)-k)/(i+j-k));
        end 
    end
    function z = H_x(x,y)
        z = 0;
        for a = (i+j+1):n
            f = 1/(i+j-a);
            for b = (i+j+1):n
                if(b~=a)
                   f = f * (n*x + n*y - b)/(i-b); 
                end
            end
            z = z + f;
        end
    end
    function z = H_y(x,y)
       z = 0;
       for a = (i+j+1)
          f = 1/(i+j-a);
          for b = (i+j+1):n
                if(b~=a)
                   f = f * (n*x + n*y - b)/(i+j-b); 
                end
          end
          z = z + f;
       end
    end
end
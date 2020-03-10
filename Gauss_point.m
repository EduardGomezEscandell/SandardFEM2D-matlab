classdef Gauss_point < handle
    properties
        id
        w       % [1x1]                 Weight
        Z       % [n_dimensions x 1]    Coordinate(s) of the point (isoparametric)
        N       % [1 x n_shape_funs]    Value of the shape functions at this point
        gradN   % [n_dimensions x n_shape_funs] Gradients of the shape functions at this point
    end
    methods
        function obj = Gauss_point(id, w, Z)
            obj.id = id;
            obj.w = w;
            obj.Z = Z;
        end
        
        function X = changeCoords(obj, domain, Xelement)
            % Returns the converted coordinates from isoparametric space to 
            % x-y space
            % Xelement must be such that:
            % - rows are the vertex nodes
            % - columns the coordinate (x, y, z)
            
            switch domain.n_dimensions
                case 1 % 1D element
                    X = (obj.z + 1)/2*(x2 - x1) + x1;
                
                case 2
                    if domain.elem_type == 'T'
                        % Triangular element
                        X = obj.Z * Xelement;
                    elseif domain.elem_type == 'Q'
                        % Quad element
                        % X = 
                    end
                case 3
                      
                otherwise
                    error('Only dimensions 1-3 are supported')
            end
        end
        
        function triangle_shape_fun(obj,x,y,n)
            switch n % Order of interpolation
                case 1
                    % Linear
                    obj.N{1} = 1 - x - y;
                    obj.N{2} = x;
                    obj.N{3} = y;
                    obj.gradN{1} = [-1, -1]';
                    obj.gradN{2} = [ 1,  0]';
                    obj.gradN{3} = [ 0,  1]';
                case 2
                    % Quadratic
                    obj.N{1} =4*(x/2 + y/2 - 1/4)*(x + y - 1);
                    obj.N{2} =4*x*(x/2 - 1/4);
                    obj.N{3} =4*y*(y/2 - 1/4);
                    obj.N{4} =-4*x*(x + y - 1);
                    obj.N{5} =4*x*y;
                    obj.N{6} =-4*y*(x + y - 1);
                    obj.gradN{1} = [4*x + 4*y - 3, 4*x + 4*y - 3]';
                    obj.gradN{2} = [4*x - 1,  0]';
                    obj.gradN{3} = [0,  4*y - 1]';
                    obj.gradN{4} = [4 - 4*y - 8*x,  -4*x]';
                    obj.gradN{5} = [4*y,  4*x]';
                    obj.gradN{6} = [-4*y,  4 - 8*y - 4*x]';
                otherwise
                    error('Higher-than-quadratic shape functions unavailable');
            end
        end
    end
end
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
            obj.Z = reshape(Z,[1 length(Z)]);
        end
        
        function segment_shape_fun(obj,x,n)
            switch n
                case 1
                    % Linear
                    obj.N{1} = 0.5*(1 - x);
                    obj.N{2} = 0.5*(1 + x);
                    obj.gradN{1} = -0.5;
                    obj.gradN{2} =  0.5;
                case 2
                    % Quadratic
                    obj.N{1} = 0.5 * x * (1 - x);
                    obj.N{2} = (1 - x^2);
                    obj.N{3} = 0.5 * x * (1 + x);
                    obj.gradN{1} = 0.5 - x;
                    obj.gradN{2} = -2*x;
                    obj.gradN{3} = 0.5 + x;
                otherwise
                    error('Higher-than-quadratic shape functions unavailable');
            end
        end
        
        function triangle_shape_fun(obj,n)
            corners = [0 0; 1 0; 0 1];
            X = obj.Z * corners;
            x = X(1);
            y = X(2);
            
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
        
        function quad_shape_fun(obj,n)      % quadrilateral element shape functions
            x = obj.Z(1);
            y = obj.Z(1);
            switch n % Order of interpolation
                case 1
                    % Linear
                    obj.N{1} = (1-x)*(1-y)/4;
                    obj.N{2} = (1+x)*(1-y)/4;
                    obj.N{3} = (1+x)*(1+y)/4;
                    obj.N{4} = (1-x)*(1+y)/4;
                    
                    obj.gradN{1} = [(y-1)/4, (x-1)/4]';
                    obj.gradN{2} = [(1-y)/4, -(1+x)/4]';
                    obj.gradN{3} = [(1+y)/4, (1+x)/4]';
                    obj.gradN{4}  = [-(1+y)/4, (1-x)/4]';
                    
                case 2
                    % Quadratic (9 nodes)
                    obj.N{1} = 1/4*(1-x)*(1-y)*x*y;
                    obj.N{2} = -1/4*(1+x)*(1-y)*x*y;
                    obj.N{3} = 1/4*(1+x)*(1+y)*x*y;
                    obj.N{4} = -1/4*(1-x)*(1+y)*x*y;
                    obj.N{5} = -1/2*(1-x^2)*(1-y)*y;
                    obj.N{6} = 1/2*(1+x)*(1-y^2)*x;
                    obj.N{7} = 1/2*(1-x^2)*(1+y)*y;
                    obj.N{8} = -1/2*(1-x)*(1-y^2)*x;
                    obj.N{9} = (1-x^2)*(1-y^2);
                    
                    obj.gradN{1} = 1/4*[y*(1-2*x)+y^2*(2*x-1), x*(1-2*y)+x^2*(2*y-1)]';
                    obj.gradN{2} = -1/4*[y*(1+2*x)-y^2*(2*x+1), x*(1-2*y)+x^2*(1-2*y)]';
                    obj.gradN{3} = 1/4*[(1+2*x)*(y+y^2), (1+2*y)*(x+x^2)]';
                    obj.gradN{4} = -1/4*[(1-2*x)*(y+y^2), (1+2*y)*(x-x^2)]';
                    obj.gradN{5} = -1/2*[2*x*y*(y-1), 1-2*y-x^2+2*x^2*y]';
                    obj.gradN{6} = 1/2*[1-y^2+2*x-2*x*y^2, -2*x*y*(x+1)]';
                    obj.gradN{7} = 1/2*[-2*x*y*(y+1), 1+2*y-x^2-2*x^2*y]';
                    obj.gradN{8} = -1/2*[1-y^2-2*x+2*x*y^2, 2*x*y*(x-1)]';
                    obj.gradN{9} = [2*x*(y^2-1), 2*y*(x^2-1)]';

                otherwise
                    error('Higher-than-quadratic shape functions unavailable');
            end
        end
    end
end
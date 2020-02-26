classdef Gauss_point < handle
    properties
        w       % [1x1]                 Weight
        Z       % [n_dimensions x 1]    Coordinate(s) of the point (isoparametric)
        N       % [1 x n_shape_funs]    Value of the shape functions at this point
        gradN   % [n_dimensions x n_shape_funs] Gradients of the shape functions at this point
    end
    methods
        function obj = Gauss_point(w, Z)
            obj.w = w;
            obj.Z = Z;
        end
        
        function X = changeCoords(Xelement)
            % Returns the converted coordinates from isoparametric space to 
            % x-y space
            
            if size(Xelement,1) ==1 % 1D element
                X = (obj.z + 1)/2*(x2 - x1) + x1;
                
            elseif size(Xelement,1) ==2  % 2D element
                if size(Xelement,2) == 3
                    % Triangular element
                    % X =
                elseif size(Xelement,2) == 4
                    % Quad element
                    % X = 
                end
            end
        end
    end
end
classdef Material < handle
    properties
       id
       name % Name of the material
       E    % Young modullus
       v    % Poisson modullus
       D    % Constutive matrix
       dens % Density
       k    % Thermal coefficient
    end
    
    methods
        function obj = Material(id, attribute_list)
            obj.id = id;
            for attribute = attribute_list
                if strcmp(attribute.Name,'name')
                    obj.name = attribute.Value;
                elseif strcmp(attribute.Name,'E')
                    obj.E = str2double(attribute.Value);
                elseif strcmp(attribute.Name,'Poisson')
                    obj.v = str2double(attribute.Value);
                elseif strcmp(attribute.Name,'Density')
                    obj.dens = str2double(attribute.Value);
                elseif strcmp(attribute.Name,'Thermal')
                    obj.k = str2double(attribute.Value);
                else
                    warn(['Material property ', attribute.Name,' not recognized']);
                end
            end
        end
        
        function obj = calcConstitutive(obj, problemType)
            
            if(problemType == 1) % 1 -- Plane stress
                obj.D = [ 1  obj.v 0;
                        obj.v  1   0;
                        0      0  1-obj.v];
                obj.D = obj.E / (1 - obj.v^2) * obj.D;
                
            elseif(problemType == 2) % 2 -- Plain strain
                obj.D = [ 1-obj.v    obj.v   0;
                           obj.v   1-obj.v   0;
                             0         0  1-2*obj.v];
                obj.D = obj.E / (1 + obj.v) / (1 - 2*obj.v) * obj.D;
            end
            
        end
    end
end
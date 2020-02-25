classdef Material < handle
    properties
       id
       E
       v
       D
    end
    
    methods
        function obj = Material(id, Young, Poisson)
            obj.id = id;
            obj.E = Young;
            obj.v = Poisson;
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
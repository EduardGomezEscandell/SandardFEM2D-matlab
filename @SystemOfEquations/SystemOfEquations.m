classdef SystemOfEquations < handle
    properties
       n
       K
       b
       u
       isSolved = false
    end
    methods
        function obj = SystemOfEquations(n)
            obj.n = n;
            obj.K = zeros(n);
            obj.b = zeros(n,1);
            obj.u = NaN * zeros(n,1);
        end
        
        function obj = solve(obj)
           obj.u = obj.K \ obj.b;
           obj.isSolved = true;
        end
        
        function obj = assemble_laplacian(obj)
            for i=2:obj.n
               obj.K(i,i) = 2;
               obj.K(i,i-1) = -1;
               obj.K(i-1,i) = -1;
            end
            obj.K(1,1) = 2;
            obj.K(end,end) = 1;
            obj.b(end) = 1;
        end
        
        obj = assemble_thermal(obj, dom)
        obj = assemble_stress_2D(obj, dom)
        
        function obj = plotResult(obj)
            plot(obj.u);
            grid on;
            xlabel('Node');
            ylabel('u');
        end
    end
end
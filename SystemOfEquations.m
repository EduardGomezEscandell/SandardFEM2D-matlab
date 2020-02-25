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
            obj.u = zeros(n,1) * NaN;
        end
        
        function obj = solve(obj)
           obj.u = obj.K \ obj.b;
           obj.isSolved = true;
        end
        
        function obj = assemble(obj)
            for i=2:obj.n
               obj.K(i,i) = 2;
               obj.K(i,i-1) = -1;
               obj.K(i-1,i) = -1;
            end
            obj.K(1,1) = 2;
            obj.K(end,end) = 1;
            obj.b(end) = 1;
        end
        
        function obj = plotResult(obj)
            plot(obj.u);
            grid on;
            xlabel('Node');
            ylabel('u');
        end
    end
end
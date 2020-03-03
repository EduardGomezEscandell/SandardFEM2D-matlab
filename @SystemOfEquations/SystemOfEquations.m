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
        
        function obj = fake_solution(obj, domain, solution_fun)
            for i=1:domain.n_nodes
                sol = solution_fun(domain.nodes{i}.X);
                for j=1:domain.DOF_per_node
                    obj.u((i-1)*domain.n_dimensions + j) = sol(j);
                end
            end
            obj.isSolved = true;
        end
        
        obj = assemble_thermal(obj, dom)
        obj = assemble_stress_2D(obj, dom)
        plotResult(obj, domain)
        export_to_vtk(obj, domain, input_dir)
        
    end
end
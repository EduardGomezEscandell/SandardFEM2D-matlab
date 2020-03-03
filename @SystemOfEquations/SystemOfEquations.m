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
               obj.u(i) = solution_fun(domain.nodes{i}.X);
            end
            isSolved = true;
        end
        
        obj = assemble_thermal(obj, dom)
        obj = assemble_stress_2D(obj, dom)
        
        function obj = plotResult(obj, domain)
            switch(domain.n_dimensions)
                case 1
                    plot(obj.u);
                    grid on;
                    xlabel('Node');
                    ylabel('u');
                case 2
                    switch(domain.elem_type)
                        case 'T'
                            % Triangular elements
                            for el = 1:domain.n_elems
                                element = domain.elems{el};
                                X = zeros(3,3);
                                for i=1:3
                                    X(i,1:2) = element.nodes{i}.X;
                                    node_id = element.nodes{i}.id;
                                	X(i,3) = obj.u(node_id);
                                end
                                trisurf([1,2,3],X(:,1),X(:,2),X(:,3));
                                hold on
                            end
                            colorbar
                            xlabel('x')
                            ylabel('y')
                            zlabel('u')
                            hold off
                        case 'Q'
                            % Quad elements
                    end
            end
        end
    end
end
classdef SystemOfEquations < handle
    properties
       n  % Size of the system
       K  % Stiffnes matrix
       b  % Load vector
       
       H  % Lagrangian multipliers matrix
       e  % Lagrangian multipliers vector
       
       u  % Solution vector
       u_clean  % Solution matrix where each row is a node
       isSolved = false % Solved flag
    end
    methods
        function obj = SystemOfEquations(domain)
            n = domain.n_nodes * domain.DOF_per_node + domain.n_dirichlet;
            obj.n = n;
            obj.K = zeros(n);
            obj.b = zeros(n,1);
            obj.H = zeros(domain.n_dirichlet, domain.n_nodes);
            obj.e = zeros(domain.n_dirichlet, 1);
            obj.u = NaN * zeros(n,1);
        end
        
        function solve(obj)
           obj.u = obj.K \ obj.b;
           obj.isSolved = true;
        end
        
        function clean_solution(obj, domain)
            obj.u_clean = zeros(domain.n_nodes, domain.DOF_per_node);
            i = 1;
            for node_cell = domain.nodes
                node = node_cell{1};
                for j = 1:domain.DOF_per_node
                    obj.u_clean(node.id, j) = obj.u(i);
                    i = i + 1;
                end
            end
        end
        
        function assemble(obj, domain, gauss_data)
            switch domain.problem_type
                case -1
                    obj.assemble_thermal(domain, gauss_data)
                case 1
                    obj.assemble_stress_2D(domain, gauss_data)
            end
        end
        
        function assemble_laplacian(obj)
            for i=2:obj.n
               obj.K(i,i) = 2;
               obj.K(i,i-1) = -1;
               obj.K(i-1,i) = -1;
            end
            obj.K(1,1) = 2;
            obj.K(end,end) = 1;
            obj.b(end) = 1;
        end
        
        function enforce_boundaries(obj, domain)
            % Using the lagrangian multipliers method
            
            % Assembling matrix H and vector e
            i = 1;
            for node_cell = domain.nodes
                node = node_cell{1};
                for j = 1:domain.DOF_per_node
                    if(node.BC_type(j) == 'D')
                        obj.e(i) = node.BC_value(j);
                        obj.H(i, node.id) = 1;
                        i = i + 1;
                    end
                end
            end
            
            % Copying into equation system
            obj.K(domain.n_nodes+1:end,1:domain.n_nodes) = obj.H;
            obj.K(1:domain.n_nodes,domain.n_nodes+1:end) = obj.H';
            obj.b(domain.n_nodes+1:end) = obj.e;
        end
        
        function obj = fake_solution(obj, domain, solution_fun)
            for i=1:domain.n_nodes
                sol = solution_fun(domain.nodes{i}.X, domain);
                for j=1:domain.DOF_per_node
                    obj.u((i-1)*domain.DOF_per_node + j) = sol(j);
                end
            end
            obj.isSolved = true;
        end
        
        plot_result(obj, domain, exag)
        export_to_vtk(obj, domain, input_dir)
        assemble_thermal(obj, domain, gauss_data)
        assemble_stress_2D(obj, domain, gauss_data)
        
    end
end
classdef SystemOfEquations < handle
    properties
       n  % Size of the system
       K  % Stiffnes matrix
       b  % Load vector
       
       k_is_assembled % Wether assembly has finished or not 
       
       u  % Solution vector
       u_clean  % Solution matrix where each row is a node
       isSolved = false % Solved flag
    end
    methods
        function obj = SystemOfEquations(domain)
            n = domain.n_nodes * domain.DOF_per_node + domain.n_dirichlet;
            obj.n = n;
            obj.K = Sparse_dok(n);
            obj.k_is_assembled = false;
            obj.b = zeros(n,1);
            obj.u = NaN * zeros(n,1);
        end
        
        function r = residual(obj)
            if ~obj.k_is_assembled
                error('K must be assembled before operations can be performed');
            end
            r = obj.b - obj.K*obj.u;
        end
        
        function solve(obj)
            if ~obj.k_is_assembled
                error('K must be assembled before operations can be performed');
            end
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
        
        function enforce_dirichlet(obj, domain)

            for node_cell = domain.nodes
                node = node_cell{1};
                for j = 1:domain.DOF_per_node
                    if(node.BC_type(j) == 'D')
                        I = domain.n_nodes + node.dirichlet_id;
                        J = node.id;
                        obj.b(I) = node.BC_value(j);
                        obj.K.append_triplet(I,J,1);
                        obj.K.append_triplet(J,I,1);
                    end
                end
            end
        end
        
        function ax = plot_sparsity(obj)
            ax = imagesc(obj.K./obj.K);
            title('Sparsity pattern');
            colormap jet
        end
        
        plot_result(obj, domain, exag)
        export_to_vtk(obj, domain, input_dir)
        assemble_thermal(obj, domain, gauss_data)
        assemble_stress_2D(obj, domain, gauss_data)
        
    end
end
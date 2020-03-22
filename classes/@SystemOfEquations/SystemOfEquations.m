classdef SystemOfEquations < handle
    properties
       n  % Size of the system
       K  % Stiffnes matrix
       b  % Load vector
       
       k_is_assembled % Wether assembly has finished or not 
       
       u  % Solution vector
       u_clean  % Solution matrix where each row is a node
       
       grad_u  % Gradient of the solution
       
       isSolved = false % Solved flag
    end
    methods
        function obj = SystemOfEquations(domain)
            n =   domain.n_nodes * domain.DOF_per_node ...
                + domain.n_dirichlet + domain.n_neumann;
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
                case -2
                    obj.assemble_aero(domain, gauss_data)
                case -1
                    obj.assemble_thermal(domain, gauss_data)
                case 1
                    obj.assemble_stress_2D(domain, gauss_data)
            end
        end
        
        function enforce_BC(obj, domain)

            for node_cell = domain.nodes
                node = node_cell{1};
                
                if isempty(node.BC_id)
                    continue % It is a Neumann = 0
                end
                
                for j = 1:domain.DOF_per_node
                    I = domain.n_nodes*domain.DOF_per_node + node.BC_id;
                    J = node.id;
                    if(node.BC_type(j) == 'D')
                        obj.b(I) = node.BC_value(j);
                        obj.K.append_triplet(I,J,1);
                    elseif(node.BC_type(j) == 'N')
                        obj.b(I) = node.BC_value(j);
                        obj.K.append_triplet(I,I,1);
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
        calc_gradients(obj, domain, gauss_data)
        assemble_thermal(obj, domain, gauss_data)
        assemble_stress_2D(obj, domain, gauss_data)
        
    end
end
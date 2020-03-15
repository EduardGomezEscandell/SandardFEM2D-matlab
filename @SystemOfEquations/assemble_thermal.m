function assemble_thermal(obj, domain, gauss_data)
    
    obj.K.alloc_space(domain.DOF_per_node * domain.nodes_per_elem * domain.n_elems*1.5);
    
    % Looping through elements
    for el = 1:domain.n_elems
    	element = domain.elems{el};
        element.calc_jacobian_tri();
        
        % Looping through nodes --> i
    	for i = 1:domain.nodes_per_elem
            I = element.nodes{i}.id; % global coordinate
            
            % Load vector:
            
            f = 0;
            for gp_cell = gauss_data.tris'
                gp = gp_cell{1}; % Stupid matlab
                % Weak form: \int N_i·s d\Omega
                f = f + gp.w * gp.N{i} * domain.source_term;
            end
            obj.b(I) = f * element.area/2;
            
            % Stiffness matrix:
            
            % Looping through nodes --> j
    		for j = i:domain.nodes_per_elem
                J = element.nodes{j}.id; % global coordinate
                
    			% Gauss quadrature
                k = 0;
    			for gp_cell = gauss_data.tris'
                    gp = gp_cell{1}; % Stupid matlab
                    % Weak form: \int \nabla N_i�k�\nabla N_j d\Omega
                    dotprod =  (element.invJ * gp.gradN{i})' ...
                             * element.material.k ...
                             * element.invJ * gp.gradN{j};
    				k = k + gp.w * dotprod;
                end
                k = k * element.area/2;
                
                obj.K.append_triplet(I,J,k);
                if i~=j
                    % Exploiting symmetry
                    obj.K.append_triplet(J,I,k);
                end
            
            end            
    	end
    end
    
    % Obtaining fluxes
    
    switch domain.n_dimensions
        case 1
            error('One dimension not yet supported')
        case 2
            for eg = 1:domain.n_edges
                edge = domain.edges{eg};
                if ~edge.is_boundary
                    continue
                end
                
                if size(edge.material.k,1) > 1
                    % Obtaining normal vector
                    n = edge.nodes{end}.X' - edge.nodes{1}.X';
                    n = [0 1; -1 0]*n; % Rotating 90 deg to the right
                    n = n / norm(n);   % Normalizing
                else
                    n = 1;
                end

                for i = 1:domain.nodes_per_edge
                    node_i = edge.nodes{i};
                    if node_i.BC_type == 'D' % Dirichlet BC
                        for j = 1:domain.nodes_per_edge
                            node_j = edge.nodes{j};
                            if node_j.BC_type == 'D' % Dirichlet BC
                                k = 0;
                                for gp_cell = gauss_data.line'
                                    gp = gp_cell{1}; % Thanks Matlab
                                    k = k + gp.w *  gp.N{i} * gp.N{j} * n' * edge.material.k * n;
                                end
                                I = node_i.id;
                                J = node_j.dirichlet_id + domain.n_nodes*domain.DOF_per_node;
                                
                                obj.K.append_triplet(I,J,k);
                            end
                        end
                    elseif node_i.BC_type == 'N' && node_i.BC_value ~= 0   % Neumann BC
                            b = 0;
                            for gp_cell = gauss_data.line'
                                gp = gp_cell{1};
                                b = b + gp.w * gp.N{i} * node_i.BC_value;
                            end
                            I = node_i.id;
                            obj.b(I) = obj.b(I) + b;
                    end
                end
            end
            
            obj.enforce_dirichlet(domain);
            obj.K = obj.K.to_sparse();
            obj.k_is_assembled = true;

        case 3
            error('3D not yet supported')
        otherwise
            error('4D+ not supported')
    end
end
function assemble_aero(obj, domain, gauss_data)
    
    if domain.n_dimensions ~= 2
       error('Aero only implemented for 2D domains'); 
    end

    obj.K.alloc_space(domain.DOF_per_node * domain.nodes_per_elem * domain.n_elems*3);
    
    %% Load vector
    for el = 1:domain.n_elems
        element = domain.elems{el};
        if domain.elem_type == 'T'
            element.calc_jacobian_tri();
            iso_area = 2;
        else
            element.calc_jacobian_quad();
            iso_area = 4;
        end
        
        for i = 1:domain.nodes_per_elem
            I = element.nodes{i}.id; % global coordinate

            % Load vector:

            f = 0;
            for gp_cell = gauss_data.plane'
                gp = gp_cell{1}; % Stupid matlab
                % Weak form: \int N_i·s d\Omega
                f = f + gp.w * gp.N{i} * element.get_source_term(domain, gp);
            end
            obj.b(I) = f * element.area/iso_area;
        end
    end
    
    %% Stiffness Matrix
    if ~domain.is_cached
        for el = 1:domain.n_elems
            element = domain.elems{el};

            if domain.elem_type == 'T'
                element.calc_jacobian_tri();
                iso_area = 2;
            else
                element.calc_jacobian_quad();
                iso_area = 4;
            end

            % Looping through nodes --> i
            for i = 1:domain.nodes_per_elem
                I = element.nodes{i}.id; % global coordinate            

                % Looping through nodes --> j
                for j = i:domain.nodes_per_elem
                    J = element.nodes{j}.id; % global coordinate

                    % Gauss quadrature
                    k = 0;
                    for gp_cell = gauss_data.plane'
                        gp = gp_cell{1}; % Stupid matlab
                        % Weak form: \int \nabla N_i k \nabla N_j d\Omega

                        if domain.elem_type == 'T'
                            invJ = element.invJ;
                        else % Q
                            j1 = element.jacobian.j1;
                            j2 = element.jacobian.j2;
                            j3 = element.jacobian.j3;
                            jacob = 1/4 * ([j1; j2] + ([0 1;1 0]*gp.Z') * j3);
                            %                         ^ [xi, eta] --> [eta; xi]
                            invJ = inv(jacob);
                        end
                        k_aero = element.get_k_term(domain, gp);
                        dotprod =  (invJ * gp.gradN{i})'* k_aero * (invJ * gp.gradN{j});
                        k = k + gp.w * dotprod;
                    end
                    k = k * element.area/iso_area;

                    obj.K.append_triplet(I,J,k);
                    if i~=j
                        % Exploiting symmetry
                        obj.K.append_triplet(J,I,k);
                    end

                end
            end
        end
        
        domain.store_cache(obj)
    else
        adomain.load_cache(obj);
    end

    %%  Obtaining fluxes
    % Looping through edges
    for eg = 1:domain.n_edges
        edge = domain.edges{eg};
        if ~edge.is_boundary
            continue
        end

        % Obtaining length
        v = edge.nodes{end}.X' - edge.nodes{1}.X';
        edge.length = norm(v);

        % Assembling
        for i = 1:domain.nodes_per_edge
            node_i = edge.nodes{i};
            
            if isempty(node_i.BC_id)
                % It is a Neumann = 0, the integral will be zero
                continue
            end
            
            for j = i:domain.nodes_per_edge
                node_j = edge.nodes{j};
                
                if isempty(node_j.BC_id)
                    % It is a Neumann = 0, the integral will be zero
                    continue
                end

                k = 0;
                for gp_cell = gauss_data.line'
                    gp = gp_cell{1};
                    k_aero = element.get_k_term(domain, gp);
                    k = k + gp.w *  gp.N{i} * k_aero * gp.N{j};
                end
                k = k*edge.length/2;
                
                I = node_i.id;
                J = node_j.BC_id + domain.n_nodes*domain.DOF_per_node;
                obj.K.append_triplet(I,J,k);

                if(node_i.id ~= node_j.id) % Exploiting symmetry
                    I = node_j.id;
                    J = node_i.BC_id + domain.n_nodes*domain.DOF_per_node;
                    obj.K.append_triplet(I,J,k);
                end
            end

        end
    end
    obj.enforce_BC(domain);
    obj.K = obj.K.to_sparse();
    obj.k_is_assembled = true;
end
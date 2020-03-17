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
                f = f + gp.w * gp.N{i} * element.get_source_term_triangle(domain, gp);
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
    % Looping through edges
    for eg = 1:domain.n_edges
        edge = domain.edges{eg};
        if ~edge.is_boundary
            continue
        end

        % Obtaining normal vector
        if size(edge.material.k,1) > 1
            n = edge.nodes{end}.X' - edge.nodes{1}.X';
            n = [0 1; -1 0]*n; % Rotating 90 deg to the right
            n = n / norm(n);   % Normalizing
        else
            n = 1;
        end

        % Assembling
        for i = 1:domain.nodes_per_edge
            node_i = edge.nodes{i};
            if isempty(node_i.BC_id)
                continue % It is a Neumann = 0, the integral will be zero
            end
            
            for j = i:domain.nodes_per_edge
                node_j = edge.nodes{j};
                
                if isempty(node_j.BC_id)
                    continue % It is a Neumann = 0, the integral will be zero
                end

                k = 0;
                for gp_cell = gauss_data.line'
                    gp = gp_cell{1}; % Thanks Matlab for not looping through cells :(
                    k = k + gp.w *  gp.N{i} * gp.N{j} * n' * edge.material.k * n;
                end
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
function calc_gradients(obj, domain, gauss_data)
    % For now only implemented for 2D
         
    obj.grad_u = cell(domain.DOF_per_node,1);
    for k = 1:domain.DOF_per_node
        obj.grad_u{k} = zeros(domain.n_elems * size(gauss_data,1),domain.n_dimensions);
    end
    
    gp = 1;
    for el = 1:domain.n_elems
        element = domain.elems{el};
        
        for p = 1: size(gauss_data, 1)
            grad_u_local = zeros(domain.n_dimensions, domain.DOF_per_node);
            
            for i = 1:domain.nodes_per_elem
                node_id = element.nodes{i}.id;
                u = obj.u_clean(node_id,:);
                grad_u_local = grad_u_local + u * element.jacobian * gauss_data{p}.gradN{i};
            end
            
            for k = 1:domain.DOF_per_node
                obj.grad_u{k}(gp,:) = grad_u_local(:,k)';
            end
            
            gp = gp + 1;
        end
    end
    
end
function circulation = aero_calc_circulation(obj, domain, gauss_data, CENTER, RADIUS)
    % Valid for 2D domains with the object inside a circle centered around
    % CENTER with radius RADIUS

    % Circulation = Counteclockwise integral of V·ds
    % Elements are described counterclockise (hence clockwise for the holes
    % in the domain)
    
    circulation = 0;

    for eg = 1:domain.n_edges
        edge = domain.edges{eg};       
        if ~edge.is_boundary
            % Only edges needed
            continue
        elseif norm(edge.nodes{1}.X - CENTER) > RADIUS
            % Only the area of study
            continue
        end        
        
        % Director vector:
        ds = edge.nodes{end}.X - edge.nodes{1}.X;
        ds = ds'/edge.length;
        
        local_circ = 0;
        
        for p = 1:length(gauss_data.line)
            gp = gauss_data.line{p};
            U = [0; 0]; % Velocity at this gauss point
            
            for i = 1:domain.nodes_per_edge
                global_i = edge.nodes{i}.id;
                U = U + gp.N{i} * obj.grad_u{global_i};
            end
            local_circ = local_circ - gp.w * U' * ds;
        end
        local_circ = local_circ * edge.length / 2;
        
        circulation = circulation + local_circ;
    end
end
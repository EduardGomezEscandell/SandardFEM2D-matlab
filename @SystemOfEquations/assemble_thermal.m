function assemble_thermal(obj, domain, gauss_data)
    % Looping through elements
    for el = 1:domain.n_elems
    	element = domain.elems{el};
        element.calc_jacobian();
        
        % Looping through nodes --> i
    	for i = 1:domain.nodes_per_elem
            I = element.nodes{i}.id; % global coordinate
            
            % Looping through nodes --> j
    		for j = i:domain.nodes_per_elem
                J = element.nodes{j}.id; % global coordinate
                
    			% Gauss quadrature
                k = 0;
    			for g_p = gauss_data'
                    gp = g_p{1}; % Stupid matlab
                    % Weak form: \int \nabla N_i·k·\nabla N_j d\Omega
                    dotprod =  (element.invJ * gp.gradN{i})' ...
                             * element.invJ * gp.gradN{j};
    				k = k + gp.w * dotprod * element.material.k;
                end
                k = k * element.area/2;
                
                obj.K(I,J) = obj.K(I,J) + k;
                if i~=j
                    % Exploiting symmetry
                    obj.K(J,I) = obj.K(J,I) + k;
                end
            
            end
    	end
    end
end
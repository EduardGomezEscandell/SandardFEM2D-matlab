function export_to_vtk_triangular(obj, domain, project_dir, exageration)
    %%  Opening file
    output_filename = [project_dir,'/result.vtk'];
    file_out = fopen(output_filename,'w+');
    
    if(file_out < 0)
        error(['Failed to create or edit file ',output_filename]);
    end
    
    %%  Printing header
    fprintf(file_out,'# vtk DataFile Version 1.0.\nRESULT\nASCII\n\n');
    fprintf(file_out,'DATASET UNSTRUCTURED_GRID\n\n');
    
    %% Points
    % Header
    fprintf(file_out,sprintf('POINTS %6d float\n',domain.n_nodes));
    %Table
    for nd = 1:domain.n_nodes
        node_values = '';
        
        % Coordinates X,Y
        for i=1:domain.n_dimensions
            node_values = [node_values,sprintf('      %14.8E',domain.nodes{nd}.X(i))];
        end
        
        % Coordinate Z
        for j=i+1:3
            % If 2D+ dimensional solution, put a filler 0
            value_z = 0;
            if domain.DOF_per_node == 1
                % If scalar solution, plotted as z-value
                value_z = obj.u(nd) * exageration;
            end
            node_values = [node_values,sprintf('      %14.8E',value_z)];
        end
        node_values = [node_values,'\n'];
        fprintf(file_out,node_values);
    end 
    fprintf(file_out,'\n');
    
    %% Connectivities
    % Header
    cell_line = sprintf('CELLS   %d   %d\n',domain.n_elems, ...
            domain.n_elems*(domain.nodes_per_elem + 1));
    fprintf(file_out,cell_line);
    
    % Table
    for el = 1:domain.n_elems
        node_ids = sprintf('    %d',domain.nodes_per_elem);
        for i=1:domain.nodes_per_elem
            id = domain.elems{el}.nodes{i}.id - 1; % Changing to zero-indexed
            node_ids = [node_ids, sprintf(' %6d', id)];
        end
        node_ids = [node_ids,'\n'];
        fprintf(file_out,node_ids);
    end
    fprintf(file_out,'\n');
    
    %%  Cell types
    cell_type = '5'; % 5 : triangle
    fprintf(file_out,sprintf(' CELL_TYPES     %d\n',domain.n_elems));
    text_to_repeat = ['    ',cell_type];
    fprintf(file_out,repmat(text_to_repeat, [1,domain.n_elems]));
    fprintf(file_out,'\n\n');
    
    %% Point data
    fprintf(file_out,sprintf('POINT_DATA     %d\n', domain.n_nodes));
    
    if(domain.DOF_per_node == 1)
        %% Scalar solution vector
        fprintf(file_out,'SCALARS scal float\n');
        fprintf(file_out,'LOOKUP_TABLE default\n');
        for nd = 1:domain.n_nodes
            fprintf(file_out,sprintf('    %10.5E\n', exageration*obj.u(nd)));
        end
    else
        %% Higher dimension solution vector
        fprintf(file_out,'VECTORS vec float\n');
        for nd = 1:domain.n_nodes
            node_vals = '';
            for i=1:domain.n_dimensions
                val = exageration * obj.u((nd-1)*domain.n_dimensions + i);
                node_vals = [node_vals, sprintf('%15.5e    ',val)];
            end
            for j = i+1:3
                % Filler zeros to reach 3D
                node_vals = [node_vals, '0.0'];
            end
            node_vals = [node_vals,'\n'];
            fprintf(file_out, node_vals);
        end
    end
    
    %% Closing file
    fprintf(file_out,'\n\n\n\n');
    fclose(file_out);
end
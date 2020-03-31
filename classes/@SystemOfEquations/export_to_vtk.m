function export_to_vtk(obj, domain, project_dir)
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
            % Filler zeros up to 3D
            value_z = 0;
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
    
    if domain.interpolationDegree > 1
        error('Higher order elements not yet implemented');
    else
       switch domain.elem_type
            case 'Q'
                cell_type = '9'; % quad
            case 'T'
                cell_type = '5'; % tri
            otherwise
                error('Unrecognized element type');
        end 
    end
    
    fprintf(file_out,sprintf(' CELL_TYPES     %d\n',domain.n_elems));
    text_to_repeat = ['    ',cell_type];
    fprintf(file_out,repmat(text_to_repeat, [1,domain.n_elems]));
    fprintf(file_out,'\n\n');
    
    %% Point data
    fprintf(file_out,sprintf('POINT_DATA     %d\n', domain.n_nodes));
    
    if(domain.DOF_per_node == 1)
        %% Solution vector
        switch domain.problem_type
            case -1
                value_name = 'Temperature';
            case -2
                value_name = 'Potential';
            otherwise
                value_name = 'Solution';
        end
        fprintf(file_out,sprintf('SCALARS %s float\n',value_name));
        fprintf(file_out,'LOOKUP_TABLE default\n');
        for nd = 1:domain.n_nodes
            fprintf(file_out,sprintf('    %10.5E\n', obj.u(nd)));
        end
        
        %% Gradient vector
        switch domain.problem_type
            case -1
                value_name = 'Heat flux';
            case -2
                value_name = 'Velocity';
            otherwise
                value_name = 'Gradient';
        end
        fprintf(file_out,'VECTORS %s float\n',value_name);
        for nd = 1:domain.n_nodes
            node_vals = '';
            for i=1:domain.n_dimensions
                val = obj.grad_u{nd}(i);
                node_vals = [node_vals, sprintf('%15.5e    ',val)];
            end
            for j = i+1:3
                % Filler zeros to reach 3D
                node_vals = [node_vals, '0.0'];
            end
            node_vals = [node_vals,'\n'];
            fprintf(file_out, node_vals);
        end
    else
        error('Higher dimensional solutions not yet supported');
    end
    
    %% Closing file
    fprintf(file_out,'\n\n\n\n');
    fclose(file_out);
end
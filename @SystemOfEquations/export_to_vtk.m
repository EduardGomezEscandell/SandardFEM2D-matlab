function export_to_vtk(obj, domain, input_dir)
    output_filename = [input_dir,'/result.vtk'];
    file_out = fopen(output_filename,'w+');
    
    if(file_out < 0)
        error(['Failed to create or edit file ',output_filename]);
    end
    
    fprintf(file_out,'# vtk DataFile Version 1.0.\rRESULT\nASCII\n\n');
    
    fprintf(file_out,'DATASET UNSTRUCTURED_GRID\n\r');
    
    % Points
    fprintf(file_out,sprintf('POINTS %6d float\n',domain.n_nodes));
    
    for nd = 1:domain.n_nodes
        node_values = '';
        node = domain.nodes{nd};
        for i=1:domain.n_dimensions
            node_values = [node_values,sprintf('      %14.8E',node.X(i))];
        end
        for j=i+1:3
            node_values = [node_values,sprintf('      %14.8E',0)];
        end
        node_values = [node_values,'\n'];
        fprintf(file_out,node_values);
    end 
    fprintf(file_out,'\r');
    
    % Connectivities
    cell_line = sprintf('CELLS   %d   %d\r',domain.n_elems, ...
            domain.n_elems*(domain.nodes_per_elem + 1));
    fprintf(file_out,cell_line);
    
    for el = 1:domain.n_elems
        element = domain.elems{el};
        node_ids = sprintf('    %d',domain.nodes_per_elem);
        for i=1:domain.nodes_per_elem
            node_ids = [node_ids, sprintf(' %6d',element.nodes{i}.id-1)];
        end
        node_ids = [node_ids,'\r'];
        fprintf(file_out,node_ids);
    end
    fprintf(file_out,'\r');
    
    % Cell types
    cell_type = '5';
    fprintf(file_out,sprintf(' CELL_TYPES     %d\r',domain.n_elems));
    mat_to_rep = ['    ',cell_type];
    for i=1:domain.n_elems
        fprintf(file_out,mat_to_rep);
    end
    fprintf(file_out,'\r\r');
    
    % Point data
    fprintf(file_out,sprintf('POINT_DATA     %d\r', domain.n_nodes));
    if(domain.DOF_per_node == 1)
        fprinf(file_out,'SCALARS scal float\r')
        fprinf(file_out,'LOOKUP_TABLE default\r')
        for nd = 1:domain.n_nodes
            fprintf(file_out,sprintf('    %10.5', obj.u(nd)));
        end
    else
        fprintf(file_out,'VECTORS vec float\r');
        for nd = 1:domain.n_nodes
            node_vals = '';
            for i=1:domain.n_dimensions
                val = obj.u((nd-1)*domain.n_dimensions + i);
                node_vals = [node_vals, sprintf('%10.5e    ',val)];
            end
            for j = i+1:3
                node_vals = [node_vals, '0.0'];
            end
            node_vals = [node_vals,'\r'];
            fprintf(file_out, node_vals);
        end
    end
    
    fclose(file_out);
end
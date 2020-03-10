function load_mesh(obj, project_dir)
     % Reads the mesh file. Called from readFromFile

    %%  Opening file
    meshFileName = [project_dir,'/mesh.fmsh'];
    meshFile = fopen(meshFileName);
    if(meshFile < 1)
        error(['Failed to find file ',meshFileName]);
    end

    %%  Various attributes
    line = fgetl(meshFile);
    data = split(line);

    obj.n_dimensions = str2double(data{3});
    obj.nodes_per_elem = str2double(data{7});

    if strcmp(data{5},'Triangle')
        obj.elem_type = 'T';
        obj.interpolationDegree = obj.nodes_per_elem / 3;
    elseif strcmp(data{5},'Quad ?')
        obj.elem_type = 'Q';
        obj.interpolationDegree = obj.nodes_per_elem / 4;
    end

    %% Nodes
    % Finding start of node list
    line = fgetl(meshFile);
    while(~strcmp(line,'Coordinates'))
        line = fgetl(meshFile);
    end

    % Running through nodes
    line = fgetl(meshFile);
    while(~strcmp(line,'End Coordinates'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(meshFile);
            continue
        end
        X = zeros(1,obj.n_dimensions);
        for i=1:obj.n_dimensions
            X(i) = str2double(data{2+i});
        end

        obj.new_node(X);

        line = fgetl(meshFile);
    end
    
    %% Element-nodes
    % Finding start of element list
    line = fgetl(meshFile);
    while(~strcmp(line,'Elements-nodes'))
        line = fgetl(meshFile);
    end

    % Running through elements
    line = fgetl(meshFile);
    while(~strcmp(line,'End Elements-nodes'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(meshFile);
            continue
        end
        
        elem_id = str2double(data{1});
        node_IDs = [];
        for i=2:obj.nodes_per_elem
            node_IDs(end+1) = str2double(data{i});
        end
        
        obj.elems{i}.add_nodes(node_IDs);
        line = fgetl(meshFile);
    end
    
    %% Edges
    % Finding start of edge list
    line = fgetl(meshFile);
    while(~strcmp(line,'Edges'))
        line = fgetl(meshFile);
    end
    
    line = fgetl(meshFile);
    while(~strcmp(line,'End Edges'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(meshFile);
            continue
        end
        
        node_IDs(2) = str2double(data{3});
        node_IDs(1) = str2double(data{2});
        obj.new_edge(node_IDs);
        
        line = fgetl(meshFile);
    end
    
    %% Elements-edges
    % Finding start of element list
    line = fgetl(meshFile);
    while(~strcmp(line,'Elements-edges'))
        line = fgetl(meshFile);
    end

    % Running through elements
    line = fgetl(meshFile);
    while(~strcmp(line,'End Elements-edges'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(meshFile);
            continue
        end
        
        edge_IDs = [];
        
        for i=2:size(data,2)
            edge_IDs(end+1) = str2double(data{i});
        end
        
        obj.new_elem(edge_IDs);

        line = fgetl(meshFile);
    end


    % Ending routine
    fclose(meshFile);
end
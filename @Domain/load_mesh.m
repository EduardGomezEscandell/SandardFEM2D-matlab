function load_mesh(obj, project_dir)
     % Reads the mesh file. Called from readFromFile

    % Opening file
    meshFileName = [project_dir,'/mesh.msh'];
    meshFile = fopen(meshFileName);
    if(meshFile < 1)
        error(['Failed to find file ',meshFileName]);
    end

    % Various attributes
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

    % Finding start of element list
    line = fgetl(meshFile);
    while(~strcmp(line,'Elements'))
        line = fgetl(meshFile);
    end

    % Running through elements
    line = fgetl(meshFile);
    while(~strcmp(line,'End Elements'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(meshFile);
            continue
        end

        node_IDs = zeros(1,obj.nodes_per_elem);
        for i=1:obj.nodes_per_elem
            node_IDs(i) = str2double(data{1+i});
        end

        obj.new_elem(node_IDs);

        line = fgetl(meshFile);
    end


    % Ending routine
    fclose(meshFile);
end
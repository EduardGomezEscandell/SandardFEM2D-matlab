function load_boundaries(obj, project_dir)
    % Reads the boundaries file. Called from readFromFile

    % Opening file
    bcFileName = [project_dir,'/boundaries.txt'];
    bcFile = fopen(bcFileName);
    if(bcFile < 1)
        error(['Failed to find file ',bcFileName]);
    end

    %% Dirichlet Boundary conditions
    line = fgetl(bcFile);
    while(~strcmp(line,'Dirichlet'))
        if feof(bcFile)
            return
        end
        line = fgetl(bcFile);
    end

    line = fgetl(bcFile);
    while(~strcmp(line,'End Dirichlet'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(bcFile);
            continue
        end
        
        nd = str2double(data{2});
        node = obj.nodes{nd};
        
        for i = 1:size(data,2)
            if ~strcmp(data{2+i},'-')
                node.BC_type(i) = 'D';
                node.BC_value(i) = str2double(data{2+i});
                node.dirichlet_id = obj.n_dirichlet + 1;
                obj.n_dirichlet = obj.n_dirichlet + 1;
            end
        end

        line = fgetl(bcFile);
    end
    
    %% Neumann Boundary conditions
    line = fgetl(bcFile);
    while(~strcmp(line,'Neumann'))
        if feof(bcFile)
            return
        end
        line = fgetl(bcFile);
    end

    line = fgetl(bcFile);
    while(~strcmp(line,'End Neumann'))
        data = split(line);

        if size(data,2) == 0
            line = fgetl(bcFile);
            continue
        end
        
        nd = str2double(data{2});
        node = obj.nodes{nd};
        
        for i = 1:size(data,2)
            if ~strcmp(data{2+i},'-')
                node.BC_type(i) = 'N';
                node.BC_value(i) = str2double(data{2+i});
            end
        end

        line = fgetl(bcFile);
    end
end
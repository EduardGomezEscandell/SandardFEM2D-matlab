function load_problem_settings(obj, project_dir)
    % Reads the problem settings file

    % Opening file
    settingsFileName = [project_dir,'/problem_settings.txt'];
    settingsFile = fopen(settingsFileName);
    if(settingsFile < 1)
        error(['Failed to find file ',settingsFileName]);
    end

    while ~feof(settingsFile)
        line = fgetl(settingsFile);
        data = split(line);

        if(strcmp(data{1},'DoF_per_Node'))
            obj.DOF_per_node = str2double(data{3});
        elseif(strcmp(data{1},'integration_degree'))
            obj.integrationDegree = str2double(data{3});
        elseif(strcmp(data{1},'problem_type'))
            obj.problem_type = obtain_problem_type(data{3});
        elseif(strcmp(data{1},'source_term'))
            for i=3:size(data,1)
                obj.source_term(end+1) = str2double(data{i});
            end
        end
        % More elseifs ?
    end
end

function problem_type = obtain_problem_type(text)
    problem_type = 0;
    
    % Add items to the list to add new problem types
    problem_types = {'Thermal'      ,-1;
                    'Plane_Stress'  , 1;
                    'Plane_Strain'  , 2};
    
    for row = problem_types'
        if(strcmp(text, row{1}))
            problem_type = row{2};
            break;
        end
    end
    
    if problem_type == 0
        error(['Failed to identify problem type ',text]);
    end
end
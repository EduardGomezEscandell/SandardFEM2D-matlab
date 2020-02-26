function gaussData = loadGaussData(dom)
    if(dom.n_dimensions == 1)
        gaussData = loadGaussSegment(dom.integrationDegree);
    elseif(dom.n_dimensions == 2)
        if(dom.nodes_per_elem == 3)
            gaussData = loadGaussTriangle(integrationDegree);
        end
        % else  --> Quads
    end
    % else --> 3D
end

function gaussData = loadGaussSegment(integrationDegree)
    % Loading file
    fileGaussName = 'math_data/gauss_points_segment.txt';
    fileGauss = fopen(fileGaussName);
    if fileGauss<0
       error(['Failed to find file ', fileGaussName]);
    end
    
    % Finding integration degree
    target = ['n = ',num2str(integrationDegree+1)];
    found = false;
    line = fgetl(fileGauss);
    while ~strcmp(line,'End File')
        line = fgetl(fileGauss);
        if strcmp(line, target)
            found = true;
            break;
        end
    end
    
    if ~found
        fileGauss.fclose();
        error(['Failed to retrieve Gauss points in segment of order ',num2str(integrationDegree)]);
    end
    
    gaussData = cell(integrationDegree+1,1);
    
    % Loading data
    for i=1:integrationDegree+1
        line = fgetl(fileGauss);
        data = split(line);
        w = str2double(data(2));
        z = str2double(data(3));
        gaussData{i} = Gauss_point(w, z);
    end
    
    % Closing file
    fclose(fileGauss);
end
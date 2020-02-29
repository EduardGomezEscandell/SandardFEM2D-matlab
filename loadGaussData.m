function gaussData = loadGaussData(dom)
    if(dom.n_dimensions == 1)
        gaussData = loadGaussSegment(dom.integrationDegree);
    elseif(dom.n_dimensions == 2)
        if(dom.elem_type == 'T')
            gaussData = loadGaussTriangle(dom);
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
    while ~feof(fileGauss)
        line = fgetl(fileGauss);
        if strcmp(line, target)
            found = true;
            break;
        end
    end
    
    if ~found
        fclose(fileGauss);
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

function gaussData = loadGaussTriangle(domain)
    % Loading file
    fileGaussName = 'math_data/gauss_points_triangle.txt';
    fileGauss = fopen(fileGaussName);
    if fileGauss<0
       error(['Failed to find file ', fileGaussName]);
    end
    
    % Finding integration degree
    target = ['n = ',num2str(domain.integrationDegree+1)];
    found = false;
    line = fgetl(fileGauss);
    while ~feof(fileGauss)
        line = fgetl(fileGauss);
        data = split(line);
        if strcmp(data{1},'n') && strcmp(data{2},'=')
            n_points = str2double(data{3});
            if n_points >= domain.integrationDegree+1
                found = true;
                break;
            end
        end
    end
    
    if ~found
        fclose(fileGauss);
        error(['Failed to retrieve Gauss points in triangle of order ',num2str(domain.integrationDegree)]);
    end
    
    gaussData = cell(n_points,1);
    domain.integrationDegree = n_points-1;
    
    % Loading data
    for i=1:n_points
        line = fgetl(fileGauss);
        data = split(line);
        w = str2double(data(2));
        z = str2double(data(3));
        gaussData{i} = Gauss_point(w, z);
    end
    
    % Closing file
    fclose(fileGauss);
end
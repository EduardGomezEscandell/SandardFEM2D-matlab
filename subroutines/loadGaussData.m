function gauss_data = loadGaussData(dom)
    switch dom.n_dimensions
        case 1
            gauss_data = loadGaussSegment(dom.integrationDegree);
        case 2
            switch dom.elem_type
                case 'T'
                    gauss_data.tris = loadGaussTriangle(dom);
                    gauss_data.line = loadGaussSegment(dom.integrationDegree);
                case 'Q'
                    gauss_data = loadGaussQuad(dom);
            end
        case 3
            error('3D not yet supported')
        otherwise
            error('4D+ not supported')
    end
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
        gaussData{i} = Gauss_point(i, w, z);
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
    for id=1:n_points
        line = fgetl(fileGauss);
        data = split(line);
        L = zeros(1,3);
        L(1) = str2double(data(1));
        L(2) = str2double(data(2));
        L(3) = 1 - L(1) - L(2);
        w = str2double(data(3));
        gaussData{id} = Gauss_point(id, w, L);     
    end
    
    % Closing file
    fclose(fileGauss);
end

function gauss_data = loadGaussQuad(domain)
    gauss_data.line = loadGaussSegment(domain.integrationDegree);
    gauss_data.quad = cell(domain.integrationDegree^2, 1);
    for i = 1:domain.integrationDegree
        for j = 1:domain.integrationDegree
            Z = [gauss_data.line{i}.Z, gauss_data.line{j}.Z];
            id = (i-1)*domain.integrationDegree+j;
            w = gauss_data.line{i}.w*gauss_data.line{j}.w;
            gauss_data.quad{id} = Gauss_point(id, w, Z);
        end
    end
end
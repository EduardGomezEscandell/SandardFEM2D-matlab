classdef Domain < handle
    properties
       nodes            % Cell array of Node class
       elems            % Cell array of Element class
       materials        % Cell array of Material class
       
       n_nodes          % size of nodes
       n_elems          % size of elems
       n_materials      % size of materials
       
       n_dimensions     % number of dimensions
       elem_type        % triangle, quad?
       nodes_per_elem   % number of nodes per element
       DOF_per_node     % number of DOF per node
       
       integrationDegree % Degree of integration. Might be moved elsewhere.
       interpolationDegree % Degree of interpolation. Might be moved elsewhere.
    end
    
    methods
        function obj = Domain()
            obj.nodes = cell(0);
            obj.elems = cell(0);
            obj.materials = cell(0);
            obj.n_nodes = 0;
            obj.n_elems = 0;
            obj.n_materials = 0;
        end
        
        function obj = new_node(obj, X)
            % Creates a new node and adds it to nodes
            obj.nodes{end+1} = Node(obj.n_nodes+1,X, obj.DOF_per_node);
            obj.n_nodes = obj.n_nodes + 1;
        end
        
        function obj = new_elem(obj, node_ids)
            % Creates a new element and adds it to elems
            obj.elems{end+1} = Element(obj, obj.n_elems+1, node_ids);
            obj.n_elems = obj.n_elems+1;
        end
        
        function obj = new_material(obj, name, young, poisson, density)
           % Creates a new material and adds it to materials
           obj.materials{end+1} = Material(obj.n_materials+1, name, young, poisson, density);
           obj.n_materials = obj.n_materials + 1;
        end
        
        function obj = readFromFile(obj, fileName)
            % Reads from a file named fileName to load the geomtery
            % Will use new_node, new_elem and new_material to add them
            % Must read in order: Materials, then nodes, then elements
            
            % Placeholder for testing:
            obj.DOF_per_node = 2;
            obj.integrationDegree = 6;
            
            % The real deal:
            obj.loadMaterials(fileName);
            obj.loadMesh(fileName);
        end
        
        function obj = loadMaterials(obj, fileName)
            % Reads the materials file. Called from readFromFile
            
            % Opening file
            materialsFileName = [fileName,'/materials.mtr'];
            materialsFile = fopen(materialsFileName);
            if(materialsFile < 1)
                error(['Failed to find file ',materialsFileName]);
            end
            
            % Finding start of list
            line = fgetl(materialsFile);
            while(~strcmp(line,'Materials'))
                line = fgetl(materialsFile);
            end
            
            % Running through list
            line = fgetl(materialsFile);
            while(~strcmp(line,'End Materials'))
                data = split(line);

                if size(data,1) == 0  || data{1}(1) == '#' % Comments skipped
                    line = fgetl(materialsFile);
                    continue
                end
                
                name = data{1};
                young = str2double(data{2});
                poisson = str2double(data{3});
                density = str2double(data{4});
                
                obj.new_material(name, young, poisson, density);
                
                line = fgetl(materialsFile);
            end
            
            fclose(materialsFile);
        end
        
        function obj = loadMesh(obj, fileName)
             % Reads the mesh file. Called from readFromFile
            
            % Opening file
            meshFileName = [fileName,'/mesh.msh'];
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
    end
end
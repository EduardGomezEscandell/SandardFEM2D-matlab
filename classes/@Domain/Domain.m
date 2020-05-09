classdef Domain < handle
    properties
       nodes            % Cell array of Node class
       edges            % Cell array of Edge class
       elems            % Cell array of Element class
       materials        % Cell array of Material class
       
       n_nodes          % size of nodes
       n_edges          % size of edges
       n_elems          % size of elems
       n_materials      % size of materials
       
       n_dirichlet
       n_neumann
       source_term
       
       n_dimensions     % number of dimensions
       DOF_per_node     % number of DOF per node
       
       project_dir      % Directory of the project
       cacheFile        % File handle where cached K is stored
       is_cached        % Flag that marks wether cached file is valid
       
       problem_type     % type of problem
                            % -2 Aero potential
                            % -1 Thermal
                            % +1 Plane Stress
                            % +2 Plane Strain
                            % +3 3D stress
       
       elem_type        % triangle, quad?
       nodes_per_elem   % number of nodes per element
       nodes_per_edge   % number of nodes per edge
       
       integrationDegree % Degree of integration. Might be moved elsewhere.
       interpolationDegree % Degree of interpolation. Might be moved elsewhere.
    end
    
    methods
        %% Constructor
        function obj = Domain()
            obj.nodes = cell(0);
            obj.elems = cell(0);
            obj.materials = cell(0);
            obj.n_nodes = 0;
            obj.n_edges = 0;
            obj.n_elems = 0;
            obj.n_materials = 0;
            obj.n_dirichlet = 0;
            obj.n_neumann = 0;
        end
        
        %% Methods to read from file
        function read_from_file(obj, project_dir)
            obj.project_dir = project_dir;
            % Reads from a file named fileName to load the geomtery
            obj.load_problem_settings(project_dir);
            obj.load_materials(project_dir);
            obj.load_mesh(project_dir);
            obj.load_boundaries(project_dir);
            obj.check_cache();
            
        end
        
        function check_cache(obj)
            % Compares checksum of materials and mesh files with the
            % previous excution of the program. If they are the same, there
            % is no need to assemble most of the sttiffness matrix again.
            
            obj.is_cached = false;
            
            try
                cacheFileName = [obj.project_dir,'/.cache'];
                meshFileName = [obj.project_dir,'/mesh.fmsh'];
                materialsFileName = [obj.project_dir,'/materials.xml'];
                

                obj.cacheFile = fopen(cacheFileName,'r');
                
                mesh_cached_CS = fgetl(obj.cacheFile );
                mats_cached_CS = fgetl(obj.cacheFile );
                cached_problem = str2double(fgetl(obj.cacheFile ));
                cached_gauss = str2double(fgetl(obj.cacheFile ));
                
                mesh_check_sum = Simulink.getFileChecksum(meshFileName);
                mats_check_sum = Simulink.getFileChecksum(materialsFileName);
                
                if cached_problem == obj.problem_type        ...
                   && cached_gauss == obj.integrationDegree  ...
                   && strcmp(mesh_cached_CS, mesh_check_sum) ...
                   && strcmp(mats_cached_CS,mats_check_sum)
                       % Stiffness matrix will be the same
                       obj.is_cached = true;
                else
                    fclose(obj.cacheFile);
                end
            catch
                
            end
        end
        
        function load_cache(obj, seq)
            try
                line = fgetl(obj.cacheFile);
                while ~strcmp(line, 'EOF')
                    data = split(line);
                    row = str2double(data{2});
                    col = str2double(data{3});
                    val = str2double(data{4});
                    seq.K.append_triplet(row, col, val);                    
                    line = fgetl(obj.cacheFile);
                end
            catch
                error('There was an error reading the cached data, please delete the .cache file and run again');
            end
            fclose(obj.cacheFile);
        end
        
        %Functions defined elsewhere. All used by read_from_file
        load_mesh(obj, project_dir)
        load_materials(obj, project_dir)
        load_problem_settings(obj, project_dir)
        load_boundaries(obj, project_dir)
        
        %% Methods to add items
        
        function new_node(obj, X)
            % Creates a new node and adds it to nodes
            obj.nodes{end+1} = Node(obj.n_nodes+1,X, obj.DOF_per_node);
            obj.n_nodes = obj.n_nodes + 1;
        end
        
        function new_edge(obj, node_ids, is_boundary)
            % Creates a new edge and adds it to edges.
            obj.edges{end+1} = Edge(obj, obj.n_edges+1, node_ids, is_boundary);
            obj.n_edges = obj.n_edges + 1;
        end
        
        function new_elem(obj, node_ids, material_id, varargin)
            % Creates a new element and adds it to elems. If material_id is
            % specified, then it is prescribed. Otherwise it's assumed to
            % be material 1
            
            obj.elems{end+1} = Element(obj, obj.n_elems+1, node_ids);
            obj.n_elems = obj.n_elems+1;
            
            if nargin == 2
                obj.elems{end}.set_material(obj, 1); % Material 1 by default
            else
                obj.elems{end}.set_material(obj, material_id);
            end
        end
        
        function obj = new_material(obj, attribute_list)
           % Creates a new material and adds it to materials
           obj.materials{end+1} = Material(obj.n_materials+1, attribute_list, obj.project_dir);
           obj.n_materials = obj.n_materials + 1;
        end
        
        %% Method to draw the mesh
        
        function draw_mesh(obj, color)
            edges_list = obj.edges;
            parfor eg=1:obj.n_edges
                edge = edges_list{eg};
                X = [edge.nodes{1}.X', edge.nodes{end}.X'];
                plot(X(1,:), X(2,:), 'Color', color);
                hold on
            end
        end
        
    end
end
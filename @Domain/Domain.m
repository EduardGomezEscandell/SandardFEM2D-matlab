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
       source_term
       
       n_dimensions     % number of dimensions
       DOF_per_node     % number of DOF per node
       problem_type     % type of problem
                            % -1 Thermal
                            % +1 Plane Stress
                            % +2 Plane Strain
                            % +3 3D stress
       
       elem_type        % triangle, quad?
       nodes_per_elem   % number of nodes per element
       
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
        end
        
        %% Methods to read from file
        function read_from_file(obj, project_dir)
            % Reads from a file named fileName to load the geomtery
            obj.load_problem_settings(project_dir);
            obj.load_materials(project_dir);
            obj.load_mesh(project_dir);
            obj.load_boundaries(project_dir);
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
        
        function new_edge(obj, node_ids, is_border)
            % Creates a new edge and adds it to edges.
            obj.edges{end+1} = Edge(obj, obj.n_edges+1, node_ids, is_border);
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
           obj.materials{end+1} = Material(obj.n_materials+1, attribute_list);
           obj.n_materials = obj.n_materials + 1;
        end
        
        
    end
end
classdef Domain < handle
    properties
       nodes            % Cell array of Node class
       elems            % Cell array of Element class
       materials        % Cell array of Material class
       n_nodes          % size of nodes
       n_elems          % size of elems
       n_materials      % size of materials
       n_dimensions     % number of dimensions
       nodes_per_elem   % number of nodes per element
       integrationDegree % Degree of integration. Might be moved elsewhere.
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
            obj.nodes{end+1} = Node(obj.n_nodes+1,X);
            obj.n_nodes = obj.n_nodes + 1;
        end
        
        function obj = new_elem(obj, node_ids, material_id)
            % Creates a new element and adds it to elems
            obj.elems{end+1} = Element(obj, obj.n_elems+1, node_ids, material_id);
            obj.n_elems = obj.n_elems+1;
        end
        
        function obj = new_material(obj, Young, Poisson)
           % Creates a new material and adds it to materials
           obj.materials{end+1} = material(obj.n_materials+1, Young, Poisson);
           obj.n_materials = obj.n_materials + 1;
        end
        
        function obj = readFromFile(obj, fileName)
            % Reads from a file named fileName to load the geomtery
            % Will use new_node, new_elem and new_material to add them
            % Must read in order: Materials, then nodes, then elements
            
            % Placeholder for testing:
            obj.n_dimensions = 1;
            obj.integrationDegree = 6;
        end
    end
end
classdef Domain < handle
    properties
       nodes            % Cell array of Node class
       elems            % Cell array of Element class
       materials        % Cell array of Material class
       n_nodes          % size of nodes
       n_elems          % size of elems
       n_materials      % size of materials
    end
    
    methods
        function obj = Domain()
            obj.nodes = cell();
            obj.elems = cell();
            obj.materials = cell();
            obj.n_nodes = 0;
            obj.n_elems = 0;
            obj.n_materials = 0;
        end
        
        function obj = new_node(obj, X)
            % Creates a new node and adds it to nodes
            obj.nodes{end+1} = Node(obj.n_nodes+1,X);
        end
        
        function obj = new_elem(obj, node_ids, material_id)
            % Creates a new element and adds it to elems
            obj.elems{end+1} = Element(obj, obj.n_elems+1, node_ids, material_id);
        end
        
        function obj = new_material(obj, Young, Poisson)
           % Creates a new material and adds it to materials
           obj.materials{end+1} = material(obj.n_materials+1, Young, Poisson);
        end
        
        function obj = readFromFile(obj, fileName)
            % Reads from a file named fileName to load the geomtery
            % Will use new_node, new_elem and new_material to add them
            % Must read in order: Materials, then nodes, then elements
            % Must write
        end
    end
end
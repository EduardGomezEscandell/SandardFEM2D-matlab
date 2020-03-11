classdef Edge < handle
   properties
       id
       nodes
       is_border
   end
   methods
       function obj = Edge(domain, id, node_ids, is_border)
           obj.id = id;
           for nd = node_ids
               obj.nodes{end+1} = domain.nodes{nd};
           end
           obj.is_border = is_border;
       end
   end
end
classdef Edge < handle
   properties
       id
       nodes
   end
   methods
       function obj = Edge(domain, id, node_ids)
           obj.id = id;
           for nd = node_ids
               obj.nodes{end+1} = domain.nodes{nd};
           end
       end
   end
end
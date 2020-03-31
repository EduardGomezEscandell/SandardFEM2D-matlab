classdef Edge < handle
   properties
       id
       nodes
       is_boundary
       material   % Only relevant to evaluate fluxes
       length
   end
   methods
       function obj = Edge(domain, id, node_ids, is_boundary)
           obj.id = id;
           for nd = node_ids
               obj.nodes{end+1} = domain.nodes{nd};
           end
           obj.is_boundary = is_boundary;
       end
   end
end
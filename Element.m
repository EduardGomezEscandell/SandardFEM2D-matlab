classdef Element < handle
   properties
       id
       nodes
       material
       jacobian
   end
   methods
       function obj = Element(domain, id, node_ids)
           obj.id = id;

           obj.nodes = cell(domain.nodes_per_elem,1);
           for nd = 1:domain.nodes_per_elem
               obj.nodes{nd} = domain.nodes{node_ids(nd)};
           end
           
       end
       
       function obj = setMaterial(domain, material_id)
           obj.material = domain.materials{material_id};
       end
       
       function obj = calcJacobian(obj, domain)
           obj.jacobian = 1; % Fix
       end
       
   end
end
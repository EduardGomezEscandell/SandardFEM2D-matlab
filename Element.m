classdef Element < handle
   properties
       id
       nodes
       material
       jacobian
       invJ
       area
   end
   methods
       function obj = Element(domain, id, node_ids)
           obj.id = id;

           obj.nodes = cell(domain.nodes_per_elem,1);
           for nd = 1:domain.nodes_per_elem
               obj.nodes{nd} = domain.nodes{node_ids(nd)};
           end
           obj.area = -1;
       end
       
       function set_material(obj, domain, material_id)
           obj.material = domain.materials{material_id};
       end
       
       function obj = calc_jacobian(obj)
           if obj.area < 0
               Xa = obj.nodes{1}.X;
               Xb = obj.nodes{2}.X;
               Xc = obj.nodes{3}.X;
               obj.jacobian = [Xb(1) - Xa(1),   Xc(1) - Xa(1);
                               Xb(2) - Xa(2),   Xc(2) - Xa(2)];
               obj.invJ = obj.jacobian^-1;
               obj.area = det(obj.jacobian);
           end
           
       end
       
   end
end
classdef Element < handle
   properties
       id
       nodes
       edges
       material
       jacobian
       invJ
       area
   end
   methods
       function obj = Element(domain, id, node_ids)
           obj.id = id;
           obj.nodes = cell(domain.nodes_per_elem,1);
           obj.edges = {};
           for nd = 1:domain.nodes_per_elem
               obj.nodes{nd} = domain.nodes{node_ids(nd)};
           end
           obj.area = -1;
       end
       
       function set_edges(obj, domain, edge_ids)
           for eg = edge_ids
               obj.edges{end+1} = domain.edges{eg};
               if domain.edges{eg}.is_boundary
                    domain.edges{eg}.material = obj.material;
               end
           end
       end
       
       function set_material(obj, domain, material_id)
           obj.material = domain.materials{material_id};
       end
              
       function obj = calc_jacobian_tri(obj)
           if obj.area < 0
               v1 = obj.nodes{2}.X - obj.nodes{1}.X;
               v2 = obj.nodes{3}.X - obj.nodes{1}.X;
               
               obj.jacobian = [v1', v2']';
               obj.invJ = inv(obj.jacobian);
               obj.area = 0.5*det(obj.jacobian);
           end
       end
       
       function calc_jacobian_quad(obj)
           if obj.area < 0
               % Jacobian is not constant:
               %           [ j1 + eta * j3 ]
               % J = 1/4 * [---------------]
               %           [ j2 +  xi * j3 ]
               %
               obj.jacobian.j1 = - obj.nodes{1}.X + obj.nodes{2}.X + obj.nodes{3}.X - obj.nodes{4}.X;
               obj.jacobian.j2 = - obj.nodes{1}.X - obj.nodes{2}.X + obj.nodes{3}.X + obj.nodes{4}.X;
               obj.jacobian.j3 = + obj.nodes{1}.X - obj.nodes{2}.X + obj.nodes{3}.X - obj.nodes{4}.X;
               
               % Area is constant over element so we calculate it at
               % [xi,eta] = [0,0]
               obj.area = 4 * det([obj.jacobian.j1;obj.jacobian.j2]/4);
           end
       end
       
       
       function x = transform_coordinates_quad(obj, xi)
            Xcorners = [obj.nodes{1}.X', obj.nodes{2}.X', obj.nodes{3}.X', obj.nodes{4}.X'];
            shapefun = @(x,y)(0.25*(1-x)*(1-y));
            N = [shapefun( xi(1), xi(2));
                 shapefun(-xi(1), xi(2));
                 shapefun(-xi(1),-xi(2));
                 shapefun( xi(1),-xi(2))];
            x = Xcorners*N;
       end
       
       function q = get_source_term(obj, domain, gp)
           % Method to output source term
           if isnumeric(domain.source_term)
               q = domain.source_term;
               return
           end
           
           % Q is a function handle, must be evaluated
           switch domain.elem_type
               case 'T'
                   corners = [obj.nodes{1}.X', obj.nodes{2}.X', obj.nodes{3}.X'];
                   X = gp.Z * corners';
                   q = domain.source_term(X');
               case 'Q'
                   X = obj.transform_coordinates_quad(gp.Z);
                   q = domain.source_term(X');
           end
       end
        
       function q = get_k_term(obj, domain, gp)
           % Method to output source term
           if isnumeric(obj.material.k_aero)
               q = domain.source_term;
               return
           end
           
           % Q is a function handle, must be evaluated
           switch domain.elem_type
               case 'T'
                   corners = [obj.nodes{1}.X', obj.nodes{2}.X', obj.nodes{3}.X'];
                   X = gp.Z * corners';
                   q = obj.material.k_aero(X');
               case 'Q'
                   X = obj.transform_coordinates_quad(gp.Z);
                   q = obj.material.k_aero(X');
           end
        end
       
   end
end
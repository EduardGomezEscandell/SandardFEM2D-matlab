classdef Node < handle
   properties
      id
      X
      BC_type
      BC_value
      BC_id
   end
   methods
       function obj = Node(id, X, n_DOF)
           obj.id = id;
           obj.X = X;
           obj.BC_type = repmat('N',1,n_DOF); % BC by defalult Neumann=0
           obj.BC_value = zeros(1,n_DOF);
       end
   end
end
classdef Node < handle
   properties
      id
      X
   end
   methods
       function obj = Node(id, X)
           obj.id = id;
           obj.X = X;
       end
   end
end
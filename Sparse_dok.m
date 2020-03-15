classdef Sparse_dok < handle
    properties
        cols
        rows
        vals
        n_entries
        n_size
    end
    methods
        function obj = Sparse_dok(n)
            obj.n_size = n;
            obj.n_entries = 0;
        end
        
        function alloc_space(obj, space)
            space = ceil(space);
            obj.cols = zeros(space,1);
            obj.rows = zeros(space,1);
            obj.vals = zeros(space,1);
        end
        
        function append_triplet(obj, i,j,x)
            obj.n_entries = obj.n_entries + 1;
            obj.rows(obj.n_entries) = ifelse(i>0, i, obj.n_size-i);
            obj.cols(obj.n_entries) = ifelse(j>0, j, obj.n_size-j);
            obj.vals(obj.n_entries) = x;
        end
                
        function A = to_sparse(obj)
            A = sparse(obj.rows(1:obj.n_entries), ...
                       obj.cols(1:obj.n_entries), ...
                       obj.vals(1:obj.n_entries));
        end
        
    end
end

function ret = ifelse(cond, case_true, case_false)
    if cond
        ret = case_true;
    else
        ret = case_false;
    end
end
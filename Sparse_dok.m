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
            % Initializes a Dictionary of Keys sparse square matrix. n is 
            % the number of rows/columns.
            obj.n_size = n;
            obj.n_entries = 0;
            obj.cols = [];
            obj.rows = [];
            obj.vals = [];
        end
        
        function alloc_space(obj, space)
            % Allocates new room for the arrays so they are not constantly 
            % resized. If more space than finally needed is allocated, the
            % extra empty entries will not be used.
            space = ceil(space);
            obj.cols = [obj.cols, zeros(1,space)];
            obj.rows = [obj.rows, zeros(1,space)];
            obj.vals = [obj.vals, zeros(1,space)];
        end
        
        function append_triplet(obj, i,j,x)
            % Appends a new triplet at the end of the list. i and j can be
            % negative and they'll be interpreted as end-i or end-j
            % (similar to python).
            if x ~= 0
                obj.n_entries = obj.n_entries + 1;
                obj.rows(obj.n_entries) = ifelse(i>0, i, obj.n_size-i);
                obj.cols(obj.n_entries) = ifelse(j>0, j, obj.n_size-j);
                obj.vals(obj.n_entries) = x;
                
                if abs(i) > obj.n_size || abs(j) > obj.n_size
                    error('Appended triplet is outside matrix size')
                end
            end
        end
                
        function A = to_sparse(obj)
            % Transforms itself into a Matlab built-in sparse matrix
            A = sparse(obj.rows(1:obj.n_entries), ...
                       obj.cols(1:obj.n_entries), ...
                       obj.vals(1:obj.n_entries));
        end
        
    end
end

function output = ifelse(cond, case_true, case_false)
    % Function to clean up notation. Works exactly like MS Excel's IF 
    % function. Given an input and a true and false case, it returns the 
    % case_true if cond is true and case_false if cond is false. 
    if cond
        output = case_true;
    else
        output = case_false;
    end
end
function export_to_vtk(obj, domain, project_dir, exageration)
    switch domain.n_dimensions
        case 1
            % TODO 1D
        case 2
            switch domain.elem_type
                case 'T' % Triangle
                    obj.export_to_vtk_triangular(domain, project_dir, exageration)
                case 'Q' % Quad
            end
        case 3
            % TODO 3D
        otherwise
            error('Domains above 3 dimensions are not supported')
    end
end
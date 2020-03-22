function plot_gradients(domain, seq, gauss_data, component)
    switch domain.elem_type
        case 'T'
            gauss_data = gauss_data.tris;
        case 'Q'
            gauss_data = gauss_data.quad;
        otherwise
            error('Unrecognized element type')
    end
    
    to_plot = [];
    n_gauss = domain.n_elems*size(gauss_data,1);
    
    switch component
        case 'vec'
            read_components = @(x)(x);
        case 'abs'
            read_components = @(x)(sqrt(x*x'));
            to_plot = zeros(n_gauss,1);
        case 'x'
            read_components = @(x)(x(1));
            to_plot = zeros(n_gauss,1);
        case 'y'
            read_components = @(x)(x(2));
            to_plot = zeros(n_gauss,1);
        otherwise
            error('Unrecognized component')
    end
    
    X = zeros(n_gauss, 2);
    
    switch domain.elem_type
        case 'T'
            
            gp = 1;
            for el = 1:domain.n_elems
                element = domain.elems{el};
                for p = 1: size(gauss_data, 1)
                    Xcorners = [element.nodes{1}.X; element.nodes{2}.X; element.nodes{3}.X];
                    X(gp,:) = gauss_data{p}.Z * Xcorners;
                    
                    if size(to_plot,1) ~= 0
                        to_plot(gp) = read_components(seq.grad_u{1}(gp,:));
                    end
                    
                    gp = gp + 1;
                end
            end
            
        case 'Q'
            % TODO
            error('Quad elements not yet supported');
            
        otherwise
            error('Unrecognized element type')
    end
    
    
    
    colorwheel = {'b','r','g','k'};
    
    switch component
        case 'vec'
            for dof = 1:domain.DOF_per_node
                quiver(X(:,1), X(:,2), seq.grad_u{dof}(:,1), seq.grad_u{dof}(:,2),colorwheel{dof});
                hold on
            end
        otherwise
            warning('Plotting absolute value or individual gradient components is still a work in progress');
            T = delaunay(X);
            tricontour(T, X(:,1), X(:,2), to_plot, 10);
    end
    hold off
end
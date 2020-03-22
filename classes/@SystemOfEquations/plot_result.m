function plot_result(obj, domain, exag)
    switch(domain.n_dimensions)
        case 1
            plot(obj.u);
            grid on;
            xlabel('Node');
            ylabel('u');
        case 2
            switch(domain.elem_type)
                case 'T'
                    % Triangular elements
                    for el = 1:domain.n_elems
                        element = domain.elems{el};
                        for i=1:3
                            X(i,1:2) = element.nodes{i}.X;
                            node_id = element.nodes{i}.id;
                            switch(domain.DOF_per_node)
                                case 1
                                    X(i,3) = obj.u(node_id);
                                case 2
                                    X_mod(i,:) = X(i,:) + exag*obj.u_clean(node_id);
                            end
                        end
                        
                        switch(domain.DOF_per_node)
                            case 1
                                trisurf([1,2,3],X(:,1),X(:,2),X(:,3));
                            case 2
                                X(4,:) = X(1,:);
                                X_mod(4,:) = X_mod(1,:);
                                plot(X(:,1),X(:,2),'k');
                                plot(X_mod(:,1),X_mod(:,2),'b');
                        end
                        hold on
                    end
                    colorbar
                    xlabel('x')
                    ylabel('y')
                    zlabel('u')
                    hold off
                case 'Q'
                    % Quad elements
            end
    end
end
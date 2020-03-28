function plot_gradients(obj, domain)
    
    X = zeros(domain.n_nodes,1);
    Y = zeros(domain.n_nodes,1);
    U = zeros(domain.n_nodes,1);
    V = zeros(domain.n_nodes,1);

    
    for i=1:domain.n_nodes
        X(i) = domain.nodes{i}.X(1);
        Y(i) = domain.nodes{i}.X(2);
        U(i) = obj.grad_u{i}(1);
        V(i) = obj.grad_u{i}(2);
    end

    quiver(X,Y,U,V);

end
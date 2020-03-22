clear;

N{1} = @(x,y)(4*(x/2 + y/2 - 1/4)*(x + y - 1));
N{2} = @(x,y)(4*x*(x/2 - 1/4));
N{3} = @(x,y)(4*y*(y/2 - 1/4));
N{4} = @(x,y)(-4*x*(x + y - 1));
N{5} = @(x,y)(4*x*y);
N{6} = @(x,y)(-4*y*(x + y - 1));

corners = [0 0
           1 0
           0 1]';

n = 20;

[Xgrid, Ygrid] = meshgrid(linspace(0,1,n),linspace(0,1,n));
fun = 1
while fun < 10
    if fun == 7
        fun = 1;
    end
    X = [];
    Y = [];
    Z = [];
    s = 1;
    for i = 1:size(Xgrid,2)
        for j=1:size(Xgrid,2)-i+1
            X(s) = Xgrid(i,j);
            Y(s) = Ygrid(i,j);
            Z(s) = N{fun}(Xgrid(i,j),Ygrid(i,j));
            s = s + 1;
        end
    end
    plot3([0, 1 0 0]',[0 0 1 0]',[0 0 0 0]','k','LineWidth',2);
    hold on
    plot3([.5 .5 0 .5]',[0 .5 .5 0],[0 0 0 0],'k','LineWidth',2);

    T = delaunay(X,Y);
    trisurf(T,X,Y,Z);
    shading interp
    colorbar
    hold off
    axis([0 1 0 1 -.2 1])
    pause(0.5)
    fun = fun+1
end
hold off
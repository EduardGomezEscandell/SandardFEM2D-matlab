function q = source_term(X)
	q = 5e5*sin(5*pi*X(1))*sin(5*pi*X(2));
end
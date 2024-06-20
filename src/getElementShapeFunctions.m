%* ----- SHAPE FUNCTIONS ----- *%
function shape_functions = getElementShapeFunctions
  shape_functions = cell(1,10);

  %! truss shape functions
  shape_functions{1} = @(x, L) 1 - x./L;
  shape_functions{2} = @(x, L) x./L;

  %! beam - bending shape functions
  shape_functions{3} = @(x, L) 2.*(x.^3)./(L.^3) - 2.*(x.^2)./(L.^2) + 1;
  shape_functions{4} = @(x, L) (x.^3)./(L.^2) - 2.*(x.^2)./L + x;
  shape_functions{5} = @(x, L) -2.*(x.^3)./(L.^3) + 3.*(x.^2)./(L.^2);
  shape_functions{6} = @(x, L) (x.^3)./(L.^2) - (x.^2)./L;

  %! beam - derivatives of bending shape functions
  shape_functions{7} = @(x, L) 6.*(x.^2)./(L.^3) - 4.*(x)./(L.^2);
  shape_functions{8} = @(x, L) 3.*(x.^2)./(L.^2) - 4.*(x)./L + 1;
  shape_functions{9} = @(x, L) -6.*(x.^2)./(L.^3) + 6.*(x)./(L.^2);
  shape_functions{10} = @(x, L) 3.*(x.^2)./(L.^2) - 2.*(x)./L;
end
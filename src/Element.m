classdef Element < handle
  properties (GetAccess = private, SetAccess = private)
    n1 (1,1) Node
    n2 (1,1) Node
  end

  methods
    %* ----- ELEMENT CONSTRUCTOR ----- *%
    function obj = Element(n1,n2)
      arguments
        n1 (1,1) Node
        n2 (1,1) Node
      end
      obj.n1 = n1;
      obj.n2 = n2;
    end

    %* ----- ACCESSOR METHODS ----- *%
    function n1 = getNodeOne(obj)
      n1 = obj.n1;
    end
    function n2 = getNodeTwo(obj)
      n2 = obj.n2;
    end

    function endpoints = getEndpoints(obj)
      endpoints = [obj.getNodeOne.getX, obj.getNodeOne.getY;...
                  obj.getNodeTwo.getX, obj.getNodeTwo.getY];
    end
    function l = getElementLength(obj)
      endpoints = obj.getEndpoints;
      l = sqrt((endpoints(2,1) - endpoints(1,1))^2 + (endpoints(2,2) - endpoints(1,2))^2);
    end

    function K = getElementStiffness(obj)
      L = obj.getElementLength;
      %*                  ax1     perp1     bend1       ax2     perp2     bend2
      K = 1 / (60 * L) * [1,      0,        0,          -1,     0,        0;...
                          0,      36,       3*L,        0,      -36,      3*L;...
                          0,      3*L,      4*L^2,      0,      -3*L,     -L^2;...
                          -1,     0,        0,          1,       0,       0;...
                          0,      -36,      -3*L,       0,      36,       -3*L;...
                          0,      3*L,      -L^2,       0,      -3*L,     4*L^2];
    end

    function T = getElementTransformation(obj)
      endpoints = obj.getEndpoints;
      theta = atan((endpoints(2,2) - endpoints(1,2))/(endpoints(2,1) - endpoints(1,1)));
      T = [cos(theta),  sin(theta), 0,  0,           0,          0;...
          sin(theta),   cos(theta), 0,  0,           0,          0;...
          0,            0,          1,  0,           0,          0;...
          0,            0,          0,  cos(theta),  sin(theta), 0;...
          0,            0,          0,  sin(theta),  cos(theta), 0;...
          0,            0,          0,  0,           0,          1];
    end
  end
end
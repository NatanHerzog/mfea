classdef Element < handle
  properties (GetAccess = private, SetAccess = private)
    n1 (1,1) Node = Node(0,0)
    n2 (1,1) Node = Node(0,0)
    YOUNGS_MODULUS (1,1) double = 1
    SECOND_MOMENT (1,1) double = 1
    CROSS_SECTIONAL_AREA (1,1) double = 1
  end

  methods
    %* ----- ELEMENT CONSTRUCTOR ----- *%
    function obj = Element(~)
    end

    %* ----- ACCESSOR METHODS ----- *%
    function n1 = getNodeOne(obj)
      n1 = obj.n1;
    end
    function n2 = getNodeTwo(obj)
      n2 = obj.n2;
    end
    function E = getYoungsModulus(obj)
      E = obj.YOUNGS_MODULUS;
    end
    function I = getSecondMoment(obj)
      I = obj.SECOND_MOMENT;
    end
    function A = getCrossSectionalArea(obj)
      A = obj.CROSS_SECTIONAL_AREA;
    end

    %* ----- SETTER METHODS ----- *%
    function setNodes(obj, n1, n2)
      arguments
        obj Element
        n1 Node
        n2 Node
      end
      obj.n1 = n1;
      obj.n2 = n2;
    end
    function setYoungsModulus(obj, E)
      arguments
        obj Element
        E (1,1) double
      end
      obj.YOUNGS_MODULUS = E;
    end
    function setSecondMoment(obj, I)
      arguments
        obj Element
        I (1,1) double
      end
      obj.SECOND_MOMENT = I;
    end
    function setCrossSectionalArea(obj, A)
      arguments
        obj Element
        A (1,1) double
      end
      obj.CROSS_SECTIONAL_AREA = A;
    end

    %* ----- ELEMENT DIMENSIONS ----- *%
    function endpoints = getEndpoints(obj)
      endpoints = [obj.getNodeOne.getX, obj.getNodeOne.getY;...
                  obj.getNodeTwo.getX, obj.getNodeTwo.getY];
    end
    function l = getElementLength(obj)
      endpoints = obj.getEndpoints;
      l = sqrt((endpoints(2,1) - endpoints(1,1))^2 + (endpoints(2,2) - endpoints(1,2))^2);
    end

    %* ----- STIFFNESS MATRIX ----- *%
    function K = getElementStiffness(obj)
      L = obj.getElementLength;
      E = obj.getYoungsModulus;
      I = obj.getSecondMoment;
      A = obj.getCrossSectionalArea;
      %*   ax1          perp1           bend1           ax2           perp2           bend2
      K = [E*A/(L),     0,              0,              -E*A/(L),     0,              0;...
           0,           12*E*I/L^3,     6*E*I/L^2,      0,            -12*E*I/L^3,    6*E*I/L^2;...
           0,           6*E*I/L^2,      4*E*I/L,        0,            -6*E*I/L^2,     2*E*I/L;...
           -E*A/(L),    0,              0,              E*A/(L),      0,              0;...
           0,           -12*E*I/L^3,    -6*E*I/L^2,     0,            12*E*I/L^3,     -6*E*I/L^2;...
           0,           6*E*I/L^2,      2*E*I/L,        0,            -6*E*I/L^2,     4*E*I/L];
    end

    %* ----- TRANSFORMATION MATRIX ----- *%
    function T = getElementTransformation(obj)
      endpoints = obj.getEndpoints;
      theta = atan((endpoints(2,2) - endpoints(1,2))/(endpoints(2,1) - endpoints(1,1)));
      %*   ax1            perp1           bend1     ax2             perp2           bend2
      T = [cos(theta),    -sin(theta),    0,        0,              0,              0;...
           sin(theta),    cos(theta),     0,        0,              0,              0;...
           0,             0,              1,        0,              0,              0;...
           0,             0,              0,        cos(theta),     -sin(theta),    0;...
           0,             0,              0,        sin(theta),     cos(theta),     0;...
           0,             0,              0,        0,              0,              1];
    end
  end
end
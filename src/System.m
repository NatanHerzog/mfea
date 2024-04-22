classdef System < handle
  properties (GetAccess = private, SetAccess = private)
    nodes (1,1) NodeList
    elems (1,1) ElementList

    YOUNGS_MODULUS (1,1) double
    SECOND_MOMENT_OF_AREA (1,1) double
    CROSS_SECTIONAL_AREA (1,1) double
  end

  methods
    function obj = System(E,I,A)
      arguments
        E (1,1) double
        I (1,1) double
        A (1,1) double
      end
      obj.YOUNGS_MODULUS = E;
      obj.SECOND_MOMENT_OF_AREA = I;
      obj.CROSS_SECTIONAL_AREA = A;
    end

    function nl = getNodes(obj)
      nl = obj.nodes;
    end
    function el = getElements(obj)
      el = obj.elems;
    end

    function E = E(obj)
      E = obj.YOUNGS_MODULUS;
    end
    function I = I(obj)
      I = obj.SECOND_MOMENT_OF_AREA;
    end
    function A = A(obj)
      A = obj.CROSS_SECTIONAL_AREA;
    end

    function obj = addNode(obj, x, y)
      arguments
        obj System
        x (1,1) double
        y (1,1) double
      end
      nl = obj.getNodes;
      nl.addNode(x,y);
    end
    function obj = addElement(obj, n1, n2)
      arguments
        obj System
        n1 (1,1) int8
        n2 (1,1) int8
      end
      el = obj.getElements;
      el.addElement(n1, n2);
    end

    function K = getStiffness(obj)
      el = obj.getElements;
      K = (obj.E * obj.I * obj.A) * el.getStiffness(obj.getNodes);
    end
  end
end
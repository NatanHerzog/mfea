classdef System < handle
  properties (GetAccess = private, SetAccess = private)
    nodes (1,1) NodeList
    elems (1,1) ElementList

    YOUNGS_MODULUS (1,1) double
    SECOND_MOMENT_OF_AREA (1,1) double
    CROSS_SECTIONAL_AREA (1,1) double

    x_boundaries (1,:) int8
    y_boundaries (1,:) int8
    r_boundaries (1,:) int8

    STIFFNESS_MATRIX (:,:) double
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

    function K = K(obj)
      el = obj.getElements;
      K = (obj.E * obj.I * obj.A) * el.getStiffness(obj.getNodes);
    end
    function K = getStiffness(obj)
      K = obj.STIFFNESS_MATRIX;
    end

    function obj = xDisplacementCondition(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      for i=1:size(loc,1)
        n = Node(loc(i,1),loc(i,2));
        index = find(obj.getNodes.getNodes == n);
        obj.x_boundaries = [obj.x_boundaries, index];
      end
    end
    function obj = yDisplacementCondition(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      for i=1:size(loc,1)
        n = Node(loc(i,1),loc(i,2));
        index = find(obj.getNodes.getNodes == n);
        obj.y_boundaries = [obj.y_boundaries, index];
      end
    end
    function obj = rotationCondition(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      for i=1:size(loc,1)
        n = Node(loc(i,1),loc(i,2));
        index = find(obj.getNodes.getNodes == n);
        obj.r_boundaries = [obj.r_boundaries, index];
      end
    end

    function obj = decrementIndices(obj, index)
      for i=1:length(obj.x_boundaries)
        if i > index
          obj.x_boundaries(i) = obj.x_boundaries(i) - 1;
        end
      end
      for i=1:length(obj.y_boundaries)
        if i > index
          obj.y_boundaries(i) = obj.y_boundaries(i) - 1;
        end
      end
      for i=1:length(obj.r_boundaries)
        if i > index
          obj.r_boundaries(i) = obj.r_boundaries(i) - 1;
        end
      end
    end
    function obj = setStiffness(obj)
      K = obj.K;
      for i=1:length(obj.x_boundaries)
        index = (obj.x_boundaries(i)-1)*3+1;
        K(index,:) = []; K(:,index) = [];
        obj.decrementIndices(index);
      end
      for i=1:length(obj.y_boundaries)
        index = (obj.y_boundaries(i)-1)*3+2;
        K(index,:) = []; K(:,index) = [];
        obj.decrementIndices(index);
      end
      for i=1:length(obj.r_boundaries)
        index = (obj.r_boundaries(i)-1)*3+3;
        K(index,:) = []; K(:,index) = [];
        obj.decrementIndices(index);
      end
      obj.STIFFNESS_MATRIX = K;
    end
  end
end
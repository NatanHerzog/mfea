classdef System < handle
  properties (GetAccess = private, SetAccess = private)
    nodes (1,1) NodeList
    elems (1,1) ElementList

    NUM_DOF (1,1) int8

    YOUNGS_MODULUS (1,1) double
    SECOND_MOMENT_OF_AREA (1,1) double
    CROSS_SECTIONAL_AREA (1,1) double

    x_boundaries (1,:) int8
    y_boundaries (1,:) int8
    r_boundaries (1,:) int8

    x_forces (:,2) double
    y_forces (:,2) double
    moments (:,2) double

    STIFFNESS_MATRIX (:,:) double
    NODAL_LOADS (:,1) double
  end

  methods
    function obj = System(E,I,A,N)
      arguments
        E (1,1) double
        I (1,1) double
        A (1,1) double
        N (1,1) int8
      end
      obj.YOUNGS_MODULUS = E;
      obj.SECOND_MOMENT_OF_AREA = I;
      obj.CROSS_SECTIONAL_AREA = A;
      obj.NUM_DOF = N;
    end

    %* ----- ACCESSOR METHODS ----- *%
    function nl = getNodeList(obj)
      nl = obj.nodes;
    end
    function el = getElementList(obj)
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
    function N = N(obj)
      N = obj.NUM_DOF;
    end

    function K = K(obj)
      el = obj.getElementList;
      switch obj.N
        case 2
          K = (obj.E * obj.A) * el.getOverallStiffness(obj.getNodeList, 2);
        case 3
          K = (obj.E * obj.I * obj.A) * el.getOverallStiffness(obj.getNodeList, 3);
          tension_indices = 1:3:size(K,1)-2;
          all_indices = 1:size(K,1);
          bending_indices = all_indices(~tension_indices);
          K(tension_indices) = K(tension_indices) .* obj.E * obj.A;
          K(bending_indices) = K(bending_indices) .* obj.E * obj.I;
      end
    end
    function K = getStiffness(obj)
      K = obj.STIFFNESS_MATRIX;
    end

    function f = getNodalLoads(obj)
      f = obj.NODAL_LOADS;
    end

    %* ----- ADDER METHODS ----- *%
    function obj = addNode(obj, x, y)
      arguments
        obj System
        x (1,1) double
        y (1,1) double
      end
      nl = obj.getNodeList;
      nl.addNode(x,y);
    end
    function obj = addElement(obj, n1, n2)
      arguments
        obj System
        n1 (1,1) int8
        n2 (1,1) int8
      end
      el = obj.getElementList;
      el.addElement(n1, n2);
    end

    %* ----- SET DOF TO 0 METHODS ----- *%
    function index = findSharedIndex(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      nodes_list = obj.getNodeList.getNodes;
      x = zeros(1,obj.getNodeList.len); y = zeros(1,obj.getNodeList.len);
      for j=1:obj.getNodeList.len
        x(j) = nodes_list(j).getX;
        y(j) = nodes_list(j).getY;
      end
      x_index = find(x == loc(1));
      y_index = find(y == loc(2));
      for j=1:length(x_index)
        shared_index = find(x_index(j) == y_index);
      end
      index = (y_index(shared_index)-1)*obj.N+1;
    end
    function obj = xDisplacementCondition(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      shared_index = findSharedIndex(obj, loc);
      obj.x_boundaries = [obj.x_boundaries, shared_index];
    end
    function obj = yDisplacementCondition(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      shared_index = findSharedIndex(obj, loc)+1;
      obj.y_boundaries = [obj.y_boundaries, shared_index];
    end
    function obj = rotationCondition(obj, loc)
      arguments
        obj System
        loc (1,2) double
      end
      if obj.N ~= 3
        throw("this system is not defined with rotational degrees of freedom");
      end
      shared_index = findSharedIndex(obj, loc)+2;
      obj.r_boundaries = [obj.r_boundaries, shared_index];
    end

    %* ----- APPLY NODAL LOADS OR MOMENTS ----- *%
    function obj = xNodalForce(obj, loc, Fx)
      arguments
        obj System
        loc (1,2) double
        Fx (1,1) double
      end
      shared_index = findSharedIndex(obj, loc);
      obj.x_forces = [obj.x_forces; [shared_index, Fx]];
    end
    function obj = yNodalForce(obj, loc, Fy)
      arguments
        obj System
        loc (1,2) double
        Fy (1,1) double
      end
      shared_index = findSharedIndex(obj, loc)+1;
      obj.y_forces = [obj.y_forces; [shared_index, Fy]];
    end
    function obj = nodalMoment(obj, loc, M)
      arguments
        obj System
        loc (1,2) double
        M (1,1) double
      end
      if obj.N ~= 3
        throw("this system is not defined with rotational degrees of freedom");
      end
      shared_index = findSharedIndex(obj, loc)+2;
      obj.moments = [obj.moments; [shared_index, M]];
    end

    %* ----- GET FINAL SYSTEM STIFFNESS MATRIX ----- *%
    function obj = setStiffnessAndLoads(obj)
      K = obj.K;
      obj.setLoads;
      obj.NODAL_LOADS
      for i=1:length(obj.x_boundaries)
        index = obj.x_boundaries(i);
        K(index,:) = []; K(:,index) = [];
        obj.NODAL_LOADS(index) = [];
        obj.decrementIndices(index);
      end
      for i=1:length(obj.y_boundaries)
        index = obj.y_boundaries(i);
        K(index,:) = []; K(:,index) = [];
        obj.NODAL_LOADS(index) = [];
        obj.decrementIndices(index);
      end
      for i=1:length(obj.r_boundaries)
        index = obj.r_boundaries(i);
        K(index,:) = []; K(:,index) = [];
        obj.NODAL_LOADS(index) = [];
        obj.decrementIndices(index);
      end
      obj.STIFFNESS_MATRIX = K;
    end
    function obj = setLoads(obj)
      obj.NODAL_LOADS = zeros(size(obj.K,1),1);
      for i=1:size(obj.x_forces,1)
        obj.NODAL_LOADS(obj.x_forces(i,1)) = obj.x_forces(i,2);
      end
      for i=1:size(obj.y_forces,1)
        obj.NODAL_LOADS(obj.y_forces(i,1)) = obj.y_forces(i,2);
      end
      for i=1:size(obj.moments,1)
        obj.NODAL_LOADS(obj.moments(i,1)) = obj.moments(i,2);
      end
    end
    function obj = decrementIndices(obj, index)
      for i=1:length(obj.x_boundaries)
        if obj.x_boundaries(i) > index
          obj.x_boundaries(i) = obj.x_boundaries(i) - 1;
        end
      end
      for i=1:length(obj.y_boundaries)
        if obj.y_boundaries(i) > index
          obj.y_boundaries(i) = obj.y_boundaries(i) - 1;
        end
      end
      for i=1:length(obj.r_boundaries)
        if obj.r_boundaries(i) > index
          obj.r_boundaries(i) = obj.r_boundaries(i) - 1;
        end
      end

      for i=1:size(obj.x_forces,1)
        if obj.x_forces(i,1) > index
          obj.x_forces(i,1) = obj.x_forces(i,1) - 1;
        end
      end
      for i=1:size(obj.y_forces,1)
        if obj.y_forces(i,1) > index
          obj.y_forces(i,1) = obj.y_forces(i,1) - 1;
        end
      end
      for i=1:size(obj.moments,1)
        if obj.moments(i,1) > index
          obj.moments(i) = obj.moments(i,1) - 1;
        end
      end
    end
  end
end
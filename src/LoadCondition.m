classdef LoadCondition < handle
  properties (GetAccess = private, SetAccess = private)
    node (1,1) Node
    load_vector (1,3) double
  end

  methods
    %* ----- CLASS CONSTRUCTOR ----- *%
    function obj = LoadCondition(node, load_vector)
      arguments
        node (1,1) Node
        load_vector (1,3) double
      end
      obj.node = node;
      obj.load_vector = load_vector;
    end

    function node = getNode(obj)
      node = obj.node;
    end
    function load_vector = getLoadVector(obj)
      load_vector = obj.load_vector;
    end
  end
end
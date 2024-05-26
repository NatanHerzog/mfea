classdef DisplacementCondition < handle
  properties (GetAccess = private, SetAccess = private)
    node (1,1) Node
    displacement_vector (1,3) double
  end

  methods
    %* ----- CLASS CONSTRUCTOR ----- *%
    function obj = DisplacementCondition(node, displacement_vector)
      arguments
        node (1,1) Node
        displacement_vector (1,3) double
      end
      obj.node = node;
      obj.displacement_vector = displacement_vector;
    end

    function node = getNode(obj)
      node = obj.node;
    end
    function displacement_vector = getDisplacementVector(obj)
      displacement_vector = obj.displacement_vector;
    end
  end
end
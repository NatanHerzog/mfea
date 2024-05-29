classdef DisplacementCondition < handle
  properties (GetAccess = private, SetAccess = private)
    node (1,1) Node
    displacement (1,1) double
    direction Direction
  end

  methods
    %* ----- CLASS CONSTRUCTOR ----- *%
    function obj = DisplacementCondition(node, displacement, direction)
      arguments
        node (1,1) Node
        displacement (1,1) double
        direction Direction
      end
      obj.node = node;
      obj.displacement = displacement;
      obj.direction = direction;
    end

    function node = getNode(obj)
      node = obj.node;
    end
    function displacement = getDisplacement(obj)
      displacement = obj.displacement;
    end
    function direction = getDirection(obj)
      direction = obj.direction;
    end
  end
end
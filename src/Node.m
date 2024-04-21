classdef Node < handle
  properties (GetAccess = private, SetAccess = private)
    x (1,1) double;
    y (1,1) double;
  end

  methods
    %* ----- NODE CONSTRUCTOR ----- *%
    function obj = Node(x,y)
      arguments
        x (1,1) double
        y (1,1) double
      end
      obj.x = x;
      obj.y = y;
    end

    %* ----- ACCESS METHODS ----- *%
    function x = getX(obj)
      x = obj.x;
    end
    function y = getY(obj)
      y = obj.y;
    end

    %* ----- SETTER METHODS ----- *%
    function setX(obj, x)
      arguments
        obj Node
        x (1,1) double
      end
      obj.x = x;
    end
    function setY(obj, y)
      arguments
        obj Node
        y (1,1) double
      end
      obj.y = y;
    end

    %* ----- COPY METHOD ----- *%
    function new_node = copy(obj)
      new_node = Node(obj.getX, obj.getY);
    end
  end
end
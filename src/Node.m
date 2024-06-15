classdef Node < handle
  properties (GetAccess = private, SetAccess = private)
    x (1,1) double = 0;
    y (1,1) double = 0;
    phi (1,1) double = 0;
  end

  methods
    %* ----- NODE CONSTRUCTOR ----- *%
    function obj = Node(~)
    end

    %* ----- ACCESS METHODS ----- *%
    function x = getX(obj)
      x = obj.x;
    end
    function y = getY(obj)
      y = obj.y;
    end
    function phi = getPhi(obj)
      phi = obj.phi;
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
    function setPhi(obj, phi)
      arguments
        obj Node
        phi (1,1) double
      end
      obj.phi = phi;
    end

    %* ----- COPY METHOD ----- *%
    function new_node = copy(obj)
      new_node = Node(obj.getX, obj.getY);
    end
  end
end
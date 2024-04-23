classdef Element < handle
  properties (GetAccess = private, SetAccess = private)
    n1 (1,1) int8
    n2 (1,1) int8
    order ElementOrder = ElementOrder.LINEAR
  end

  methods
    %* ----- ELEMENT CONSTRUCTOR ----- *%
    function obj = Element(n1,n2)
      arguments
        n1 (1,1) int8
        n2 (1,1) int8
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
    function order = getOrder(obj)
      order = obj.order;
    end

    function [x_n1, y_n1, x_n2, y_n2] = getNodalLocations(obj, nodes_list)
      arguments
        obj Element
        nodes_list NodeList
      end
      nodes = nodes_list.getNodes;
      x_n1 = nodes(obj.getNodeOne).getX;
      y_n1 = nodes(obj.getNodeOne).getY;
      x_n2 = nodes(obj.getNodeTwo).getX;
      y_n2 = nodes(obj.getNodeTwo).getY;
    end
    function l = getElementLength(obj, nodes_list)
      arguments
        obj Element
        nodes_list NodeList
      end
      [x_n1, y_n1, x_n2, y_n2] = obj.getNodalLocations(nodes_list);
      l = sqrt((x_n2 - x_n1)^2 + (y_n2 - y_n1)^2);
    end

    function K = getElementStiffness(obj, nodes_list, num_dof)
      arguments
        obj Element
        nodes_list NodeList
        num_dof (1,1) int8
      end
      L = obj.getElementLength(nodes_list);
      switch num_dof
        case 2
          K = 1 / L * [1, -1; -1, 1];
        case 3
          K = 1 / (60 * L) * [1, 0, 0, -1, 0, 0;...
                              0, 36, 3*L, 0, -36, 3*L;...
                              0, 3*L, 4*L^2, 0, -3*L, -L^2;...
                              -1, 0, 0, 1, 0, 0;...
                              0, -36, -3*L, 0, 36, -3*L;...
                              0, 3*L, -L^2, 0, -3*L, 4*L^2];
      end
    end

    function T = getElementTransformation(obj, nodes_list, num_dof)
      arguments
        obj Element
        nodes_list NodeList
        num_dof (1,1) int8
      end
      [x_n1, y_n1, x_n2, y_n2] = obj.getNodalLocations(nodes_list);
      theta = atan((y_n2 - y_n1)/(x_n2 - x_n1));
      switch num_dof
        case 2
          T = [cos(theta), sin(theta), 0, 0;...
            0, 0, cos(theta), sin(theta)];
        case 3
          T = [cos(theta), sin(theta), 0, 0, 0, 0;...
            sin(theta), cos(theta), 0, 0, 0, 0;...
            0, 0, 1, 0, 0, 0;...
            0, 0, 0, cos(theta), sin(theta), 0;...
            0, 0, 0, sin(theta), cos(theta), 0;...
            0, 0, 0, 0, 0, 1];
      end
    end

    %* ----- SETTER METHODS ----- *%
    function setElementOrder(obj, order)
      arguments
        obj Element
        order ElementOrder
      end
      obj.order = order;
    end
  end
end
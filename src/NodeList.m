classdef NodeList < handle
  properties (GetAccess = private, SetAccess = private)
    nodes (1,:) Node
  end

  methods
    %* ----- NODE LIST CONSTRUCTOR ----- *%
    function obj = NodeList(~)
    end

    %* ----- ACCESSOR ----- *%
    function nodes = getNodes(obj)
      nodes = obj.nodes;
    end
    
    function num_nodes = len(obj)
      num_nodes = length(obj.getNodes);
    end

    %* ----- ADD NODES TO LIST ----- *%
    function addNode(obj, x, y)
      arguments
        obj NodeList
        x (1,1) double
        y (1,1) double
      end
      n = Node(x,y);
      obj.nodes = [obj.nodes, n];
    end
  end
end
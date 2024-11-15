classdef NodeList < handle
  properties (GetAccess = private, SetAccess = private)
    nodes (1,:) Node
  end

  methods
    %* ----- NODE LIST CONSTRUCTOR ----- *%
    function obj = NodeList(~)
    end

    %* ----- ACCESSOR ----- *%
    function all_nodes = getAllNodes(obj)
      all_nodes = obj.nodes;
    end
    function node = getNode(obj, index)
      node_list = obj.nodes;
      node = node_list(index);
    end
    
    function num_nodes = len(obj)
      num_nodes = length(obj.getAllNodes);
    end

    %* ----- ADD NODES TO LIST ----- *%
    function addNodeByLoc(obj, x, y)
      arguments
        obj NodeList
        x (1,1) double
        y (1,1) double
      end
      n = Node;
      n.setX(x)
      n.setY(y);
      obj.nodes = [obj.nodes, n];
    end
    function addNodeByNode(obj, n)
      arguments
        obj NodeList
        n (1,1) Node
      end
      obj.nodes = [obj.nodes, n];
    end
    function makeUnique(obj)
      all_nodes = obj.nodes;
      all_nodes = unique(all_nodes, 'stable');
      obj.nodes = all_nodes;
    end

    function copied_nodes = copy(obj)
      copied_nodes = Node.empty(0, length(obj.nodes));
      for i = 1 : length(obj.nodes)
        copied_nodes(i) = obj.nodes(i).copy;
      end
    end
  end
end
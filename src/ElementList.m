classdef ElementList < handle
  properties (GetAccess = private, SetAccess = private)
    elements (1,:) Element
    nodes_list (1,1) NodeList
  end

  methods
    %* ----- ELEMENT LIST CONSTRUCTOR ----- *%
    function obj = ElementList(~)
    end

    %* ----- LINK TO NODES ----- *%
    function linkToNodes(obj, nl)
      arguments
        obj ElementList
        nl (1,1) NodeList
      end
      obj.nodes_list = nl;
    end

    %* ----- ACCESSOR ----- *%
    function elements = getElements(obj)
      elements = obj.elements;
    end
    function element = getElementByIndex(obj, index)
      element_array = obj.getElements;
      element = element_array(index);
    end
    function nodes_list = getNodeList(obj)
      nodes_list = obj.nodes_list;
    end

    function num_elem = len(obj)
      num_elem = length(obj.getElements);
    end

    %* ----- ADD ELEMENT TO LIST ----- *%
    function addElementByNodes(obj, n1, n2)
      arguments
        obj ElementList
        n1 (1,1) Node
        n2 (1,1) Node
      end
      e = Element(n1,n2);
      obj.elements = [obj.getElements, e];
    end
    function addElementByIndices(obj, index_n1, index_n2)
      arguments
        obj ElementList
        index_n1 (1,1) uint64
        index_n2 (1,1) uint64
      end
      nl = obj.getNodeList; nodes = nl.getNodes;
      obj.addElementByNodes(nodes(index_n1), nodes(index_n2));
    end

    %* ----- GET STIFFNESS MATRIX ----- *%
    function stiffness_indices = nodeListIndexToStiffnessIndices(node_list_index)
      stiffness_index = (node_list_index - 1) * 3 + 1;
      stiffness_indices = stiffness_index:stiffness_index+2;
    end

    function K = getOverallStiffness(obj)
      node_list = obj.getNodeList;
      nodes = node_list.getNodes;

      K = zeros(length(nodes) * 3);
      for element_index = 1 : length(all_elements)
        current_element = obj.getElementByIndex(element_index);
        current_element_nodes = current_element.getEndpoints;
        index_n1_in_node_list = find(nodes, current_element_nodes(1));
        index_n2_in_node_list = find(nodes, current_element_nodes(2));
        all_stiffness_indices = [nodeListIndexToStiffnessIndices(index_n1_in_node_list),...
                                 nodeListIndexToStiffnessIndices(index_n2_in_node_list)];
        K(all_stiffness_indices, all_stiffness_indices) = current_element.getElementTransformation * current_element.getElementStiffness;
      end
    end
  end
end
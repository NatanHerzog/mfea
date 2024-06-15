classdef ElementList < handle
  properties (GetAccess = private, SetAccess = private)
    elements (1,:) Element
    nodes_list (1,1) NodeList
    stiffness_matrix (:,:) double

    CROSS_SECTIONAL_AREA (1,1) double = 1;
    SECOND_MOMENT_OF_AREA (1,1) double = 1;
    YOUNGS_MODULUS (1,1) double = 1;
  end

  methods
    %* ----- ELEMENT LIST CONSTRUCTOR ----- *%
    function obj = ElementList(A, I, E)
      arguments
        A (1,1) double
        I (1,1) double
        E (1,1) double
      end
      obj.CROSS_SECTIONAL_AREA = A;
      obj.SECOND_MOMENT_OF_AREA = I;
      obj.YOUNGS_MODULUS = E;
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
    function elements = getElementList(obj)
      elements = obj.elements;
    end
    function element = getElementByIndex(obj, index)
      element_array = obj.getElementList;
      element = element_array(index);
    end
    function nodes_list = getNodeList(obj)
      nodes_list = obj.nodes_list;
    end

    function num_elem = len(obj)
      num_elem = length(obj.getElementList);
    end
    function K = getStiffnessMatrix(obj)
      K = obj.stiffness_matrix;
    end

    %* ----- ADD ELEMENT TO LIST ----- *%
    function addElementByNodes(obj, n1, n2)
      arguments
        obj ElementList
        n1 (1,1) Node
        n2 (1,1) Node
      end
      e = Element;
      e.setNodes(n1,n2);
      obj.elements = [obj.getElementList, e];
    end
    function addElementByIndices(obj, index_n1, index_n2)
      arguments
        obj ElementList
        index_n1 (1,1) uint64
        index_n2 (1,1) uint64
      end
      nl = obj.getNodeList; nodes = nl.getAllNodes;
      obj.addElementByNodes(nodes(index_n1), nodes(index_n2));
    end

    %* ----- SET ELEMENT PROPERTIES IN BULK ----- *%
    function setMaterialPropertiesInBulk(obj)
      obj.setCrossSectionalArea(obj.CROSS_SECTIONAL_AREA);
      obj.setSecondMoment(obj.SECOND_MOMENT_OF_AREA);
      obj.setYoungsModulus(obj.YOUNGS_MODULUS);
    end
    function setCrossSectionalArea(obj, A)
      arguments
        obj ElementList
        A (1,1) double
      end
      elementlist = obj.getElementList;
      for element_index = 1 : obj.len
        elementlist(element_index).setCrossSectionalArea(A);
      end
    end
    function setSecondMoment(obj, I)
      arguments
        obj ElementList
        I (1,1) double
      end
      elementlist = obj.getElementList;
      for element_index = 1 : obj.len
        elementlist(element_index).setSecondMoment(I);
      end
    end
    function setYoungsModulus(obj, E)
      arguments
        obj ElementList
        E (1,1) double
      end
      elementlist = obj.getElementList;
      for element_index = 1 : obj.len
        elementlist(element_index).setYoungsModulus(E);
      end
    end

    %* ----- STORE STIFFNESS MATRIX ----- *%
    function K = calculateOverallStiffness(obj)
      node_list = obj.getNodeList;
      nodes = node_list.getAllNodes;

      K = zeros(length(nodes) * 3);
      for element_index = 1 : obj.len
        current_element = obj.getElementByIndex(element_index);
        current_element_nodes = [current_element.getNodeOne, current_element.getNodeTwo];
        index_n1_in_node_list = find(nodes == current_element_nodes(1));
        index_n2_in_node_list = find(nodes == current_element_nodes(2));
        all_stiffness_indices = [nodeListIndexToStiffnessIndices(index_n1_in_node_list),...
                                 nodeListIndexToStiffnessIndices(index_n2_in_node_list)];
        T = current_element.getElementTransformation;
        K(all_stiffness_indices, all_stiffness_indices) = K(all_stiffness_indices, all_stiffness_indices) + T * current_element.getElementStiffness * transpose(T);
      end
      obj.stiffness_matrix = K;
    end
  end
end
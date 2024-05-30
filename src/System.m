classdef System < handle
  properties (GetAccess = private, SetAccess = private)
    element_list ElementList
    loads (1,:) LoadCondition
    displacements (1,:) DisplacementCondition
  end

  methods
    %* ----- CLASS CONSTRUCTOR ----- *%
    function obj = System(element_list)
      arguments
        element_list ElementList
      end
      obj.element_list = element_list;
    end

    %* ----- ADDER METHODS ----- *%
    function addLoad(obj, node, load_vector)
      arguments
        obj System
        node (1,1) Node
        load_vector (1,3) double
      end
      load = LoadCondition(node, load_vector);
      obj.loads = [obj.loads, load];
    end
    function addDisplacement(obj, node, displacement, direction)
      arguments
        obj System
        node (1,1) Node
        displacement (1,1) double
        direction Direction
      end
      displacement = DisplacementCondition(node, displacement, direction);
      obj.displacements = [obj.displacements, displacement];
    end

    function loads = getLoads(obj)
      loads = obj.loads;
    end
    function displacements = getDisplacements(obj)
      displacements = obj.displacements;
    end

    %* ----- GET STIFFNESS MATRIX ----- *%
    function nodal_displacements = solve(obj)
      obj.element_list.setMaterialPropertiesInBulk;
      obj.element_list.calculateOverallStiffness;
      all_displacements = obj.getDisplacements;
      if ~isempty(all_displacements)
        stiffness_matrix = obj.element_list.getStiffnessMatrix;
        all_system_nodes = obj.element_list.getNodeList.getAllNodes;
        copied_nodes = all_system_nodes(:);
        
        extracted_indices = uint64.empty(0,length(all_displacements));
        for displacements_index = 1 : length(all_displacements)
          applied_node = all_displacements(displacements_index).getNode;
          applied_node_index = find(copied_nodes == applied_node);
          full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
          extracted_indices(displacements_index) = full_matrix_indices(all_displacements(displacements_index).getDirection.real);
        end

        all_loads = obj.getLoads;
        load_vector = zeros(length(all_loads), 1);
        for load_index = 1 : length(all_loads)
          applied_node = all_loads(load_index).getNode;
          applied_node_index = find(copied_nodes == applied_node);
          full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
          load_vector(full_matrix_indices) = all_loads(load_index).getLoadVector;
        end

        load_vector(extracted_indices) = [];
        stiffness_matrix(extracted_indices, :) = [];
        stiffness_matrix(:, extracted_indices) = [];

        nodal_displacements = stiffness_matrix \ load_vector';
      else
        throw(MEexception('System:Solve', 'system is not constrained, will result in rigid-body motion'));
      end
    end
  end
end
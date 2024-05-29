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
    function addLoad(obj, load)
      arguments
        obj System
        load (1,1) LoadCondition
      end
      obj.loads = [obj.loads, load];
    end
    function addDisplacement(obj, displacement)
      arguments
        obj System
        displacement (1,1) DisplacementCondition
      end
      obj.displacements = [obj.displacements, displacement];
    end

    function loads = getLoads(obj)
      loads = obj.loads;
    end
    function displacements = getDisplacements(obj)
      displacements = obj.displacements;
    end

    %* ----- GET STIFFNESS MATRIX ----- *%
    function stiffness_matrix = getSystemStiffness(obj)
      stiffness_matrix = obj.element_list.getStiffnessMatrix;
      all_displacements = obj.getDisplacements;
      system_node_list = obj.element_list.getNodeList;
      all_system_nodes = system_node_list.getAllNodes;
      copied_nodes = all_system_nodes(:);
      if ~isempty(all_displacements)
        for displacements_index=1:length(all_displacements)
          current_displacement_condition = all_displacements(displacements_index);
          applied_node = current_displacement_condition.getNode;
          applied_node_index = find(copied_nodes == applied_node);
          full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
          full_matrix_index = full_matrix_indices(current_displacement_condition.getDirection.real);
          stiffness_matrix(full_matrix_index, :) = [];
          stiffness_matrix(:, full_matrix_index) = [];

          remove_node = true;
          if ~(displacements_index == length(all_displacements))
            for remaining_displacements_index = displacements_index+1:length(all_displacements)
              checked_displacement = all_displacements(remaining_displacements_index);
              if applied_node == checked_displacement.getNode
                remove_node = false;
              end
            end
          end
          if remove_node
            copied_nodes(applied_node_index) = [];
          end
        end
      else
        throw(MEexception('system is not constrained, will result in rigid-body motion'));
      end
    end
  end
end
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

    function constrained_stiffness_matrix_indices = constrainedStiffnessMatrixIndices(obj, nodes, num_displacements)
      arguments
        obj System
        nodes (1,:) Node
        num_displacements (1,1) uint64
      end
      all_displacements = obj.getDisplacements;
      constrained_stiffness_matrix_indices = uint64.empty(0, num_displacements);
      for displacements_index = 1 : num_displacements
        applied_node = all_displacements(displacements_index).getNode;
        applied_node_index = find(nodes == applied_node);
        full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
        constrained_stiffness_matrix_indices(displacements_index) = full_matrix_indices(all_displacements(displacements_index).getDirection.real);
      end
    end

    function global_load_vector = compileGlobalLoadVector(obj)
      all_loads = obj.getLoads;
      global_load_vector = zeros(length(copied_nodes) * 3, 1);
      for load_index = 1 : length(all_loads)
        applied_node = all_loads(load_index).getNode;
        applied_node_index = find(copied_nodes == applied_node);
        full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
        global_load_vector(full_matrix_indices) = all_loads(load_index).getLoadVector;
      end
    end

    %* ----- SOLVE NODAL DISPLACEMENTS ----- *%
    function all_nodal_displacements = solveNodalDisplacements(obj)
      obj.element_list.setMaterialPropertiesInBulk;
      obj.element_list.calculateOverallStiffness;
      all_displacements = obj.getDisplacements;
      if ~isempty(all_displacements)
        all_system_nodes = obj.element_list.getNodeList.getAllNodes;
        all_nodal_displacements = zeros(1, length(all_system_nodes) * 3);
        
        unfixed_indices = 1:(length(all_system_nodes) * 3);
        constrained_stiffness_matrix_indices = obj.constrainedStiffnessMatrixIndices(all_system_nodes, length(all_displacements));
        unfixed_indices(constrained_stiffness_matrix_indices) = [];

        global_load_vector = obj.compileGlobalLoadVector;
        global_load_vector(constrained_stiffness_matrix_indices) = [];

        stiffness_matrix = obj.element_list.getStiffnessMatrix;
        stiffness_matrix(constrained_stiffness_matrix_indices, :) = [];
        stiffness_matrix(:, constrained_stiffness_matrix_indices) = [];

        nodal_displacements = stiffness_matrix \ global_load_vector;
        all_nodal_displacements(unfixed_indices) = nodal_displacements;
      else
        throw(MException('System:Solve', 'system is not constrained, will result in rigid-body motion'));
      end
    end

    %* ----- SOLVE ----- *%
    function soln = solve(obj)
      soln = obj.solveNodalDisplacements;
      copied_nodes = Node.empty(0, obj.element_list.getNodeList.len);
      for i = 1 : obj.element_list.getNodeList.len
        full_matrix_indices = nodeListIndexToStiffnessIndices(i);
        current_nodal_displacements = soln(full_matrix_indices);
        copied_nodes(i).setX(current_nodal_displacements(1)).setY(current_nodal_displacements(2)).setPhi(current_nodal_displacements(3));
      end
    end
  end
end
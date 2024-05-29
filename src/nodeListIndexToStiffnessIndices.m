function stiffness_indices = nodeListIndexToStiffnessIndices(node_list_index)
  stiffness_index = (node_list_index - 1) * 3 + 1;
  stiffness_indices = stiffness_index : stiffness_index + 2;
end
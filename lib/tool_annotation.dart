class Tool {
  final String name;
  final String description;

  /// Optional: override the entire "parameters" object.
  // final Map<String, dynamic>? overrideParameters;

  /// Optional: specific fields that should be marked as required
  final List<String>? requiredFields;

  /// Optional: property ordering override
  final List<String>? propertyOrdering;

  const Tool({
    required this.name,
    required this.description,
    // this.overrideParameters,
    this.requiredFields,
    this.propertyOrdering,
  });
}

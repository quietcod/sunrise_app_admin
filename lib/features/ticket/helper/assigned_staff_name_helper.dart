String buildAssignedStaffName(Map<String, dynamic> ticket) {
  final assignedName = (ticket['assigned_name'] ?? '').toString().trim();
  if (assignedName.isNotEmpty) return assignedName;

  final assignedFullName =
      (ticket['assigned_full_name'] ?? '').toString().trim();
  if (assignedFullName.isNotEmpty) return assignedFullName;

  final firstName = (ticket['assigned_firstname'] ?? '').toString().trim();
  final lastName = (ticket['assigned_lastname'] ?? '').toString().trim();
  final fullName = '$firstName $lastName'.trim();

  if (fullName.isNotEmpty) return fullName;

  final rawAssigned = (ticket['assigned'] ?? '').toString().trim();
  if (rawAssigned.isNotEmpty && int.tryParse(rawAssigned) == null) {
    return rawAssigned;
  }

  return 'Unassigned';
}

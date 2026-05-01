class StaffMember {
  final int staffId;
  final String firstName;
  final String lastName;
  final String email;
  final String profileImage;
  final String fullName;

  StaffMember({
    required this.staffId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImage,
    required this.fullName,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstname'] ?? '').toString();
    final lastName = (json['lastname'] ?? '').toString();
    final apiFullName = (json['full_name'] ?? '').toString().trim();
    final rawId =
        (json['staffid'] ?? json['staff_id'] ?? json['id'] ?? '').toString();

    return StaffMember(
      staffId: int.tryParse(rawId) ?? 0,
      firstName: firstName,
      lastName: lastName,
      email: (json['email'] ?? '').toString(),
      profileImage: (json['profile_image'] ?? '').toString(),
      fullName:
          apiFullName.isNotEmpty ? apiFullName : '$firstName $lastName'.trim(),
    );
  }
}

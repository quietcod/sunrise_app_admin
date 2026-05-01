class ContactPostModel {
  final String customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String title;
  final String phone;
  final String password;
  final bool isPrimary;
  final bool isActive;
  final bool invoiceEmails;
  final bool estimateEmails;
  final bool creditNoteEmails;
  final bool contractEmails;
  final bool taskEmails;
  final bool projectEmails;
  final bool ticketEmails;
  final List<int> permissions;

  ContactPostModel({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.title,
    required this.phone,
    required this.password,
    this.isPrimary = false,
    this.isActive = true,
    this.invoiceEmails = false,
    this.estimateEmails = false,
    this.creditNoteEmails = false,
    this.contractEmails = false,
    this.taskEmails = false,
    this.projectEmails = false,
    this.ticketEmails = false,
    this.permissions = const [],
  });
}

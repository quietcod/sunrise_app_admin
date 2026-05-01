class TaxesModel {
  TaxesModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(TaxItem.fromJson(v)));
    }
  }
  TaxesModel() : data = [];
  String? message;
  List<TaxItem>? data;
}

class TaxItem {
  TaxItem.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    taxrate = json['taxrate']?.toString();
  }
  String? id;
  String? name;
  String? taxrate;
}

// ─────────────────────────────────────────────────────────────────────────────

class PaymentModesModel {
  PaymentModesModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(PaymentModeItem.fromJson(v)));
    }
  }
  PaymentModesModel() : data = [];
  String? message;
  List<PaymentModeItem>? data;
}

class PaymentModeItem {
  PaymentModeItem.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    active = json['active']?.toString();
    invoicesOnly = json['invoices_only']?.toString();
    expensesOnly = json['expenses_only']?.toString();
    showOnPdf = json['show_on_pdf']?.toString();
  }
  String? id;
  String? name;
  String? description;
  String? active;
  String? invoicesOnly;
  String? expensesOnly;
  String? showOnPdf;

  bool get isActive => active == '1';
}

// ─────────────────────────────────────────────────────────────────────────────

class DepartmentsModel {
  DepartmentsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(DepartmentItem.fromJson(v)));
    }
  }
  DepartmentsModel() : data = [];
  String? message;
  List<DepartmentItem>? data;
}

class DepartmentItem {
  DepartmentItem.fromJson(dynamic json) {
    id = json['departmentid']?.toString() ?? json['id']?.toString();
    name = json['name']?.toString();
    email = json['email']?.toString();
    hideFromClient = json['hidefromclient']?.toString();
  }
  String? id;
  String? name;
  String? email;
  String? hideFromClient;
}

// ─────────────────────────────────────────────────────────────────────────────

class ClientGroupsModel {
  ClientGroupsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(ClientGroupItem.fromJson(v)));
    }
  }
  ClientGroupsModel() : data = [];
  String? message;
  List<ClientGroupItem>? data;
}

class ClientGroupItem {
  ClientGroupItem.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
  }
  String? id;
  String? name;
}

// ─────────────────────────────────────────────────────────────────────────────

class RolesModel {
  RolesModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(RoleItem.fromJson(v)));
    }
  }
  RolesModel() : data = [];
  String? message;
  List<RoleItem>? data;
}

class RoleItem {
  RoleItem.fromJson(dynamic json) {
    id = json['roleid']?.toString() ?? json['id']?.toString();
    name = json['name']?.toString();
  }
  String? id;
  String? name;
}

// ─────────────────────────────────────────────────────────────────────────────

class ContractTypesModel {
  ContractTypesModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(ContractTypeItem.fromJson(v)));
    }
  }
  ContractTypesModel() : data = [];
  String? message;
  List<ContractTypeItem>? data;
}

class ContractTypeItem {
  ContractTypeItem.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
  }
  String? id;
  String? name;
}

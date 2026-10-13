// Auth fixtures mirror the four app identities configured in production
// `LoginView(appName, appPurpose, intendedUsers)` call sites and the
// password / one-time-code methods from `login_provider.dart`.
enum ProtoAuthApp { staff, customer, owner, crm }

extension ProtoAuthAppX on ProtoAuthApp {
  String get nameKey => switch (this) {
        ProtoAuthApp.staff => 'login.app.staff',
        ProtoAuthApp.customer => 'login.app.customer',
        ProtoAuthApp.owner => 'login.app.owner',
        ProtoAuthApp.crm => 'login.app.crm',
      };

  String get purposeKey => switch (this) {
        ProtoAuthApp.staff => 'login.purpose.staff',
        ProtoAuthApp.customer => 'login.purpose.customer',
        ProtoAuthApp.owner => 'login.purpose.owner',
        ProtoAuthApp.crm => 'login.purpose.crm',
      };

  String get usersKey => switch (this) {
        ProtoAuthApp.staff => 'login.users.staff',
        ProtoAuthApp.customer => 'login.users.customer',
        ProtoAuthApp.owner => 'login.users.owner',
        ProtoAuthApp.crm => 'login.users.crm',
      };

  bool get allowRegistration => this == ProtoAuthApp.customer;
}

const String authIdentifierFixture = 'advisor@orientworkshop.ae';
const String authOtpDemo = '528914';

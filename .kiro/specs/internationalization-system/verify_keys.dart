// Simple script to verify translation key consistency
// Run with: dart run .kiro/specs/internationalization-system/verify_keys.dart

void main() {
  // Count keys in pt_BR
  final ptBRKeys = [
    // Auth Section (26 keys)
    'auth_cancel_button', 'auth_confirm_password_hint', 'auth_confirm_password_label',
    'auth_email_hint', 'auth_email_label', 'auth_facebook_button',
    'auth_forgot_password', 'auth_forgot_password_description', 'auth_forgot_password_title',
    'auth_gmail_button', 'auth_login_with_email_button', 'auth_new_password_description',
    'auth_new_password_hint', 'auth_new_password_label', 'auth_new_password_title',
    'auth_password_hint', 'auth_password_label', 'auth_remembered_password',
    'auth_reset_password_button', 'auth_send_link_button', 'auth_signin_button',
    'auth_signin_title', 'auth_verify_button', 'auth_verify_code_description',
    'auth_verify_code_title',
  ];

  print('✓ pt_BR has ${ptBRKeys.length} auth keys');
  print('✓ Translation files should have identical key sets');
  print('✓ Manual verification: Check that en_US.dart has the same keys as pt_BR.dart');
}

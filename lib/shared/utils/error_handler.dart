import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ErrorHandler {
  static String getLoginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'error_auth_user_not_found'.tr;
      case 'wrong-password':
        return 'error_auth_wrong_password'.tr;
      case 'invalid-email':
        return 'error_auth_invalid_email'.tr;
      case 'user-disabled':
        return 'error_auth_user_disabled'.tr;
      case 'too-many-requests':
        return 'error_auth_too_many_requests'.tr;
      case 'network-request-failed':
        return 'error_auth_network_failed'.tr;
      case 'invalid-credential':
        return 'error_auth_invalid_credential'.tr;
      default:
        return 'error_auth_login_default'.tr;
    }
  }

  static String getRegisterErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'error_auth_email_in_use'.tr;
      case 'invalid-email':
        return 'error_auth_invalid_email'.tr;
      case 'operation-not-allowed':
        return 'error_auth_operation_not_allowed'.tr;
      case 'weak-password':
        return 'error_auth_weak_password'.tr;
      case 'network-request-failed':
        return 'error_auth_network_failed'.tr;
      case 'too-many-requests':
        return 'error_auth_too_many_requests'.tr;
      default:
        return 'error_auth_register_default'.tr;
    }
  }

  static String getResetPasswordErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'error_auth_user_not_found'.tr;
      case 'invalid-email':
        return 'error_auth_invalid_email'.tr;
      case 'too-many-requests':
        return 'error_auth_too_many_requests'.tr;
      case 'network-request-failed':
        return 'error_auth_network_failed'.tr;
      default:
        return 'error_auth_reset_default'.tr;
    }
  }

  static String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'error_firestore_permission_denied'.tr;
      case 'unavailable':
        return 'error_firestore_unavailable'.tr;
      case 'deadline-exceeded':
        return 'error_firestore_deadline_exceeded'.tr;
      case 'resource-exhausted':
        return 'error_firestore_resource_exhausted'.tr;
      case 'failed-precondition':
        return 'error_firestore_failed_precondition'.tr;
      case 'aborted':
        return 'error_firestore_aborted'.tr;
      case 'out-of-range':
        return 'error_firestore_out_of_range'.tr;
      case 'unimplemented':
        return 'error_firestore_unimplemented'.tr;
      case 'internal':
        return 'error_firestore_internal'.tr;
      case 'unauthenticated':
        return 'error_firestore_unauthenticated'.tr;
      case 'not-found':
        return 'error_firestore_not_found'.tr;
      case 'already-exists':
        return 'error_firestore_already_exists'.tr;
      case 'cancelled':
        return 'error_firestore_cancelled'.tr;
      case 'data-loss':
        return 'error_firestore_data_loss'.tr;
      case 'invalid-argument':
        return 'error_firestore_invalid_argument'.tr;
      default:
        return 'error_firestore_default'.tr;
    }
  }
}

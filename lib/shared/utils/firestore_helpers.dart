import 'package:cloud_firestore/cloud_firestore.dart';

/// Helpers para trabalhar com Firestore
/// Inclui conversão de Timestamp, validação de Maps e constantes de paths
class FirestoreHelpers {
  // Firestore Collection Paths
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  
  // Subcollections
  static const String progressSubcollection = 'progress';
  static const String historySubcollection = 'history';
  static const String statsSubcollection = 'stats';
  static const String lessonsSubcollection = 'lessons';
  static const String exercisesSubcollection = 'exercises';
  
  // Document IDs
  static const String gamificationStatsDoc = 'gamification';
  
  // Firestore Path Builders
  
  /// Path: users/{userId}
  static String userPath(String userId) => '$usersCollection/$userId';
  
  /// Path: users/{userId}/courses/{courseId}/progress/{lessonId}
  static String lessonProgressPath(String userId, String courseId, String lessonId) =>
      '$usersCollection/$userId/courses/$courseId/$progressSubcollection/$lessonId';
  
  /// Path: users/{userId}/history/{date}
  static String historyPath(String userId, String date) =>
      '$usersCollection/$userId/$historySubcollection/$date';
  
  /// Path: users/{userId}/stats/gamification
  static String gamificationStatsPath(String userId) =>
      '$usersCollection/$userId/$statsSubcollection/$gamificationStatsDoc';
  
  /// Path: courses/{courseId}/lessons/{lessonId}
  static String lessonPath(String courseId, String lessonId) =>
      '$coursesCollection/$courseId/$lessonsSubcollection/$lessonId';
  
  /// Path: courses/{courseId}/lessons/{lessonId}/exercises/{exerciseId}
  static String exercisePath(String courseId, String lessonId, String exerciseId) =>
      '$coursesCollection/$courseId/$lessonsSubcollection/$lessonId/$exercisesSubcollection/$exerciseId';
  
  // Timestamp Conversion Helpers
  
  /// Converte Timestamp do Firestore para DateTime
  /// Retorna null se o valor for null
  /// Retorna o próprio DateTime se já for DateTime
  /// Usa data atual como fallback em caso de erro
  static DateTime? timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    
    // Fallback: retorna data atual em caso de tipo inesperado
    return DateTime.now();
  }
  
  /// Converte DateTime para Timestamp do Firestore
  /// Retorna null se o valor for null
  static Timestamp? dateTimeToTimestamp(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
  
  /// Converte Timestamp para DateTime com fallback obrigatório
  /// Nunca retorna null - usa fallback se conversão falhar
  static DateTime timestampToDateTimeWithFallback(
    dynamic value,
    DateTime fallback,
  ) {
    if (value == null) return fallback;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return fallback;
  }
  
  // Map Validation Helpers
  
  /// Valida estrutura de exercício do tipo 'image'
  static bool validateImageExercise(Map<String, dynamic> exercise) {
    if (exercise['type'] != 'image') return false;
    
    // Campos obrigatórios
    if (!exercise.containsKey('id')) return false;
    if (!exercise.containsKey('order')) return false;
    if (!exercise.containsKey('prompt')) return false;
    if (!exercise.containsKey('word')) return false;
    if (!exercise.containsKey('wordAudio')) return false;
    if (!exercise.containsKey('options')) return false;
    
    // Validar options
    final options = exercise['options'];
    if (options is! List || options.length != 4) return false;
    
    // Cada option deve ter id, image, isCorrect
    for (final option in options) {
      if (option is! Map<String, dynamic>) return false;
      if (!option.containsKey('id')) return false;
      if (!option.containsKey('image')) return false;
      if (!option.containsKey('isCorrect')) return false;
    }
    
    return true;
  }
  
  /// Valida estrutura de exercício do tipo 'translation'
  static bool validateTranslationExercise(Map<String, dynamic> exercise) {
    if (exercise['type'] != 'translation') return false;
    
    // Campos obrigatórios
    if (!exercise.containsKey('id')) return false;
    if (!exercise.containsKey('order')) return false;
    if (!exercise.containsKey('prompt')) return false;
    if (!exercise.containsKey('word')) return false;
    if (!exercise.containsKey('wordAudio')) return false;
    if (!exercise.containsKey('options')) return false;
    
    // Validar options
    final options = exercise['options'];
    if (options is! List || options.length != 4) return false;
    
    // Cada option deve ter id, text, isCorrect
    for (final option in options) {
      if (option is! Map<String, dynamic>) return false;
      if (!option.containsKey('id')) return false;
      if (!option.containsKey('text')) return false;
      if (!option.containsKey('isCorrect')) return false;
    }
    
    return true;
  }
  
  /// Valida estrutura de exercício do tipo 'word_order'
  static bool validateWordOrderExercise(Map<String, dynamic> exercise) {
    if (exercise['type'] != 'word_order') return false;
    
    // Campos obrigatórios
    if (!exercise.containsKey('id')) return false;
    if (!exercise.containsKey('order')) return false;
    if (!exercise.containsKey('prompt')) return false;
    if (!exercise.containsKey('sentence')) return false;
    if (!exercise.containsKey('sentenceAudio')) return false;
    if (!exercise.containsKey('correctOrder')) return false;
    if (!exercise.containsKey('availableWords')) return false;
    
    // Validar correctOrder e availableWords são listas
    if (exercise['correctOrder'] is! List) return false;
    if (exercise['availableWords'] is! List) return false;
    
    return true;
  }
  
  /// Valida estrutura de exercício do tipo 'match'
  static bool validateMatchExercise(Map<String, dynamic> exercise) {
    if (exercise['type'] != 'match') return false;
    
    // Campos obrigatórios
    if (!exercise.containsKey('id')) return false;
    if (!exercise.containsKey('order')) return false;
    if (!exercise.containsKey('prompt')) return false;
    if (!exercise.containsKey('pairs')) return false;
    
    // Validar pairs
    final pairs = exercise['pairs'];
    if (pairs is! List || pairs.length != 4) return false;
    
    // Cada pair deve ter audio e text
    for (final pair in pairs) {
      if (pair is! Map<String, dynamic>) return false;
      if (!pair.containsKey('audio')) return false;
      if (!pair.containsKey('text')) return false;
    }
    
    return true;
  }
  
  /// Valida exercício baseado no tipo
  /// Retorna true se a estrutura está correta
  static bool validateExercise(Map<String, dynamic> exercise) {
    if (!exercise.containsKey('type')) return false;
    
    final type = exercise['type'];
    
    switch (type) {
      case 'image':
        return validateImageExercise(exercise);
      case 'translation':
        return validateTranslationExercise(exercise);
      case 'word_order':
        return validateWordOrderExercise(exercise);
      case 'match':
        return validateMatchExercise(exercise);
      default:
        return false;
    }
  }
  
  /// Valida estrutura de lição
  static bool validateLesson(Map<String, dynamic> lesson) {
    // Campos obrigatórios
    if (!lesson.containsKey('id')) return false;
    if (!lesson.containsKey('unitId')) return false;
    if (!lesson.containsKey('sectionId')) return false;
    if (!lesson.containsKey('order')) return false;
    if (!lesson.containsKey('exercisesCount')) return false;
    if (!lesson.containsKey('estimatedTime')) return false;
    if (!lesson.containsKey('xpReward')) return false;
    if (!lesson.containsKey('gemsReward')) return false;
    
    return true;
  }
  
  /// Valida estrutura de progresso de lição
  static bool validateLessonProgress(Map<String, dynamic> progress) {
    // Campos obrigatórios
    if (!progress.containsKey('lessonId')) return false;
    if (!progress.containsKey('unitId')) return false;
    if (!progress.containsKey('status')) return false;
    
    // Status deve ser um dos valores válidos
    final status = progress['status'];
    if (status is! String) return false;
    if (!['locked', 'not_started', 'in_progress', 'completed'].contains(status)) {
      return false;
    }
    
    return true;
  }
  
  /// Valida estrutura de histórico diário
  static bool validateDailyHistory(Map<String, dynamic> history) {
    // Campos obrigatórios
    if (!history.containsKey('date')) return false;
    if (!history.containsKey('lessonsCompleted')) return false;
    if (!history.containsKey('xpEarned')) return false;
    if (!history.containsKey('timeSpent')) return false;
    
    // Validar formato da data (YYYY-MM-DD)
    final date = history['date'];
    if (date is! String) return false;
    
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) return false;
    
    return true;
  }
}

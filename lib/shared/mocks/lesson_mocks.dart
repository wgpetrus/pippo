import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/utils/app_assets.dart';

/// Mocks de lições e exercícios para desenvolvimento e testes
class LessonMocks {
  /// Retorna dados mockados de uma lição específica
  /// Aceita qualquer courseId e busca apenas pelo lessonId
  static Map<String, dynamic>? getLesson(String courseId, String lessonId) {
    final lessons = _getAllLessons();
    
    // Tentar buscar com courseId específico primeiro
    final specificKey = '${courseId}_$lessonId';
    if (lessons.containsKey(specificKey)) {
      return lessons[specificKey];
    }
    
    // Fallback: buscar com mock_course_id
    final mockKey = 'mock_course_id_$lessonId';
    if (lessons.containsKey(mockKey)) {
      final lesson = Map<String, dynamic>.from(lessons[mockKey]!);
      // Atualizar courseId para o courseId real
      lesson['courseId'] = courseId;
      return lesson;
    }
    
    return null;
  }

  /// Retorna todos os exercícios de uma lição
  /// Aceita qualquer courseId e busca apenas pelo lessonId
  static List<Map<String, dynamic>> getExercises(String courseId, String lessonId) {
    final lesson = getLesson(courseId, lessonId);
    if (lesson == null) return [];
    return List<Map<String, dynamic>>.from(lesson['exercises'] as List);
  }

  /// Retorna todas as seções mockadas com progresso dinâmico
  /// Busca progresso real do Firestore se disponível
  /// buttonIndex determina quais lições carregar (0 = 1-9, 1 = 10-18, etc.)
  static Future<List<Map<String, dynamic>>> getSectionsWithProgress(
    String userId,
    String courseId, {
    int buttonIndex = 0,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      print('🔍 Carregando progresso das seções para userId=$userId, courseId=$courseId');
      print('  📍 Path: users/$userId/courses/$courseId/progress');
      
      // Buscar progresso de todas as lições do curso
      final progressSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .get();
      
      print('📊 Encontrados ${progressSnapshot.docs.length} documentos de progresso');
      print('  📝 IDs dos documentos: ${progressSnapshot.docs.map((d) => d.id).toList()}');
      
      // Criar mapa de progresso por lessonId
      final progressMap = <String, String>{};
      for (final doc in progressSnapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'not_started';
        progressMap[doc.id] = status;
        print('  📝 Lição ${doc.id}: $status');
      }
      
      // Calcular progresso de cada seção
      final sections = getSectionsForButton(buttonIndex);
      
      print('📋 Seções base carregadas: ${sections.length}');
      
      // Primeiro passo: calcular progresso e status base de cada seção
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        final lessons = section['lessons'] as List<String>;
        int completedCount = 0;
        
        // SEMPRE definir totalProgress baseado no tamanho do array de lições
        section['totalProgress'] = lessons.length;
        
        print('🔍 Analisando seção ${section['id']} (índice $i) com ${lessons.length} lições: $lessons');
        print('  📊 totalProgress definido: ${section['totalProgress']}');
        
        for (final lessonId in lessons) {
          final lessonStatus = progressMap[lessonId] ?? 'not_started';
          print('  📝 Lição $lessonId: $lessonStatus');
          
          if (lessonStatus == 'completed') {
            completedCount++;
          }
        }
        
        print('📈 Seção ${section['id']}: $completedCount/${section['totalProgress']} lições completadas');
        
        // Atualizar progresso da seção
        section['currentProgress'] = completedCount;
        
        // Determinar status baseado no progresso
        if (completedCount == lessons.length) {
          // Todas as lições completadas
          section['status'] = 'completed';
        } else if (completedCount > 0) {
          // Tem progresso mas não completou tudo
          section['status'] = 'in_progress';
        } else {
          // Nenhuma lição completada
          // Se é a PRIMEIRA seção do array (índice 0), começa not_started (desbloqueada)
          // Senão, começa locked (será desbloqueada no próximo passo se anterior completada)
          section['status'] = i == 0 ? 'not_started' : 'locked';
        }
        
        print('  ✅ Status calculado: ${section['status']}, progresso: ${section['currentProgress']}/${section['totalProgress']}');
      }
      
      // Segundo passo: desbloquear seções baseado na anterior
      print('🔓 Desbloqueando seções baseado na anterior...');
      for (int i = 1; i < sections.length; i++) {
        final currentSection = sections[i];
        final previousSection = sections[i - 1];
        
        print('  🔍 Verificando seção ${currentSection['id']}:');
        print('    Seção anterior (${previousSection['id']}): ${previousSection['status']}');
        print('    Seção atual: ${currentSection['status']}');
        
        // Se a seção anterior foi completada, desbloquear a atual
        if (previousSection['status'] == 'completed') {
          if (currentSection['status'] == 'locked') {
            // Se não tem progresso, muda para not_started
            // Se tem progresso, já está in_progress do primeiro passo
            currentSection['status'] = 'not_started';
            print('    ✅ Seção ${currentSection['id']} desbloqueada (anterior completada)');
          }
        }
        
        print('    📊 Status final seção ${currentSection['id']}: ${currentSection['status']} (${currentSection['currentProgress']}/${currentSection['totalProgress']})');
      }
      
      print('✅ Seções carregadas com sucesso');
      print('📦 RETORNANDO SEÇÕES:');
      for (final section in sections) {
        print('  - Seção ${section['id']}: ${section['currentProgress']}/${section['totalProgress']} (${section['status']})');
      }
      return sections;
    } catch (e) {
      print('❌ Erro ao carregar progresso das seções: $e');
      // Fallback para seções estáticas
      return getSections();
    }
  }
  
  /// Retorna as seções corretas baseado no botão/unidade ativo
  /// buttonIndex 0 = lições 1-9 (Seções 1-3), buttonIndex 1 = lições 10-18 (Seções 4-6), etc.
  static List<Map<String, dynamic>> getSectionsForButton(int buttonIndex) {
    // Cada botão tem 9 lições divididas em 3 seções de 3 lições cada
    final baseLesson = (buttonIndex * 9) + 1;
    final baseSectionNumber = (buttonIndex * 3) + 1;
    
    final sections = [
      {
        'id': '$baseSectionNumber',
        'title': 'Seção $baseSectionNumber - Básico',
        'status': 'in_progress',
        'currentProgress': 0,
        'lessons': [
          '${baseLesson}',
          '${baseLesson + 1}',
          '${baseLesson + 2}',
        ],
      },
      {
        'id': '${baseSectionNumber + 1}',
        'title': 'Seção ${baseSectionNumber + 1} - Intermediário',
        'status': 'locked',
        'currentProgress': 0,
        'lessons': [
          '${baseLesson + 3}',
          '${baseLesson + 4}',
          '${baseLesson + 5}',
        ],
      },
      {
        'id': '${baseSectionNumber + 2}',
        'title': 'Seção ${baseSectionNumber + 2} - Avançado',
        'status': 'locked',
        'currentProgress': 0,
        'lessons': [
          '${baseLesson + 6}',
          '${baseLesson + 7}',
          '${baseLesson + 8}',
        ],
      },
    ];
    
    // Calcular totalProgress dinamicamente
    for (final section in sections) {
      final lessons = section['lessons'] as List<String>;
      section['totalProgress'] = lessons.length;
    }
    
    return sections;
  }

    /// Retorna todas as seções mockadas (versão estática)
  static List<Map<String, dynamic>> getSections() {
    final sections = [
      {
        'id': '1',
        'title': 'Seção 1 - Básico',
        'status': 'in_progress',
        'currentProgress': 0,
        'lessons': ['1', '2', '3'],
      },
      {
        'id': '2',
        'title': 'Seção 2 - Intermediário',
        'status': 'locked',
        'currentProgress': 0,
        'lessons': ['4', '5', '6'],
      },
      {
        'id': '3',
        'title': 'Seção 3 - Avançado',
        'status': 'locked',
        'currentProgress': 0,
        'lessons': ['7', '8', '9'],
      },
    ];
    
    // Calcular totalProgress dinamicamente baseado no tamanho do array lessons
    for (final section in sections) {
      final lessons = section['lessons'] as List<String>;
      section['totalProgress'] = lessons.length;
    }
    
    return sections;
  }

  /// Mapa completo de todas as lições
  static Map<String, Map<String, dynamic>> _getAllLessons() {
    return {
      // SEÇÃO 1 - BÁSICO
      'mock_course_id_1': {
        'id': '1',
        'courseId': 'mock_course_id',
        'title': 'Lição 1 - Saudações',
        'description': 'Aprenda saudações básicas',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': false,
        'exercises': [
          // Exercício 1: Image - Mostrar palavra "boy" e pedir para selecionar imagem
          {
            'id': 'ex1_1',
            'type': 'image',
            'order': 0,
            'audio': 'boy',
            'word': 'boy',
            'question': 'Selecione a imagem de "boy" (menino)',
            'options': [
              {
                'id': 'boy',
                'image': AppAssets.lessonBoy,
                'isCorrect': true,
              },
              {
                'id': 'girl',
                'image': AppAssets.lessonGirl,
                'isCorrect': false,
              },
              {
                'id': 'dog',
                'image': AppAssets.lessonDog,
                'isCorrect': false,
              },
              {
                'id': 'waiter',
                'image': AppAssets.lessonWaiter,
                'isCorrect': false,
              },
            ],
          },
          // Exercício 2: Translation
          {
            'id': 'ex1_2',
            'type': 'translation',
            'order': 1,
            'audio': 'boy',
            'word': 'boy',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "boy"?',
            'options': [
              {'text': 'menino', 'isCorrect': true},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          // Exercício 3: Word Order
          {
            'id': 'ex1_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O menino corre"',
            'words': ['menino', 'O', 'corre'],
            'correctOrder': ['O', 'menino', 'corre'],
          },
          // Exercício 4: Match
          {
            'id': 'ex1_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_2': {
        'id': '2',
        'courseId': 'mock_course_id',
        'title': 'Lição 2 - Animais',
        'description': 'Aprenda nomes de animais',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          // Exercício 1: Image - Mostrar palavra "dog" e pedir para selecionar imagem
          {
            'id': 'ex2_1',
            'type': 'image',
            'order': 0,
            'audio': 'dog',
            'word': 'dog',
            'question': 'Selecione a imagem de "dog" (cachorro)',
            'options': [
              {
                'id': 'dog',
                'image': AppAssets.lessonDog,
                'isCorrect': true,
              },
              {
                'id': 'boy',
                'image': AppAssets.lessonBoy,
                'isCorrect': false,
              },
              {
                'id': 'girl',
                'image': AppAssets.lessonGirl,
                'isCorrect': false,
              },
              {
                'id': 'waiter',
                'image': AppAssets.lessonWaiter,
                'isCorrect': false,
              },
            ],
          },
          // Exercício 2: Translation
          {
            'id': 'ex2_2',
            'type': 'translation',
            'order': 1,
            'audio': 'dog',
            'word': 'dog',
            'image': AppAssets.lessonDog,
            'question': 'Qual é a tradução de "dog"?',
            'options': [
              {'text': 'cachorro', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          // Exercício 3: Word Order
          {
            'id': 'ex2_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O cachorro late"',
            'words': ['cachorro', 'O', 'late'],
            'correctOrder': ['O', 'cachorro', 'late'],
          },
          // Exercício 4: Match
          {
            'id': 'ex2_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_3': {
        'id': '3',
        'courseId': 'mock_course_id',
        'title': 'Lição 3 - Profissões',
        'description': 'Aprenda nomes de profissões',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          // Exercício 1: Image - Mostrar palavra "waiter" e pedir para selecionar imagem
          {
            'id': 'ex3_1',
            'type': 'image',
            'order': 0,
            'audio': 'waiter',
            'word': 'waiter',
            'question': 'Selecione a imagem de "waiter" (garçom)',
            'options': [
              {
                'id': 'waiter',
                'image': AppAssets.lessonWaiter,
                'isCorrect': true,
              },
              {
                'id': 'boy',
                'image': AppAssets.lessonBoy,
                'isCorrect': false,
              },
              {
                'id': 'girl',
                'image': AppAssets.lessonGirl,
                'isCorrect': false,
              },
              {
                'id': 'dog',
                'image': AppAssets.lessonDog,
                'isCorrect': false,
              },
            ],
          },
          // Exercício 2: Translation
          {
            'id': 'ex3_2',
            'type': 'translation',
            'order': 1,
            'audio': 'waiter',
            'word': 'waiter',
            'image': AppAssets.lessonWaiter,
            'question': 'Qual é a tradução de "waiter"?',
            'options': [
              {'text': 'garçom', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
            ],
          },
          // Exercício 3: Word Order
          {
            'id': 'ex3_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O garçom trabalha"',
            'words': ['garçom', 'O', 'trabalha'],
            'correctOrder': ['O', 'garçom', 'trabalha'],
          },
          // Exercício 4: Match
          {
            'id': 'ex3_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'waiter', 'text': 'garçom'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
            ],
          },
        ],
      },

      // SEÇÃO 2 - INTERMEDIÁRIO
      'mock_course_id_4': {
        'id': '4',
        'courseId': 'mock_course_id',
        'title': 'Lição 4 - Pessoas',
        'description': 'Aprenda mais sobre pessoas',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex4_1',
            'type': 'image',
            'order': 0,
            'question': 'Selecione a imagem da "menina"',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex4_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex4_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina brinca"',
            'words': ['menina', 'A', 'brinca'],
            'correctOrder': ['A', 'menina', 'brinca'],
          },
          {
            'id': 'ex4_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_5': {
        'id': '5',
        'courseId': 'mock_course_id',
        'title': 'Lição 5 - Ações',
        'description': 'Aprenda verbos de ação',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex5_1',
            'type': 'image',
            'order': 0,
            'question': 'Selecione a imagem do "menino"',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex5_2',
            'type': 'translation',
            'order': 1,
            'audio': 'run',
            'word': 'run',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "run"?',
            'options': [
              {'text': 'correr', 'isCorrect': true},
              {'text': 'andar', 'isCorrect': false},
              {'text': 'pular', 'isCorrect': false},
              {'text': 'nadar', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex5_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "Ele corre rápido"',
            'words': ['corre', 'Ele', 'rápido'],
            'correctOrder': ['Ele', 'corre', 'rápido'],
          },
          {
            'id': 'ex5_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'run', 'text': 'correr'},
              {'audio': 'walk', 'text': 'andar'},
              {'audio': 'jump', 'text': 'pular'},
              {'audio': 'swim', 'text': 'nadar'},
            ],
          },
        ],
      },
      'mock_course_id_6': {
        'id': '6',
        'courseId': 'mock_course_id',
        'title': 'Lição 6 - Revisão',
        'description': 'Revise tudo que aprendeu',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex6_1',
            'type': 'image',
            'order': 0,
            'question': 'Selecione a imagem do "cachorro"',
            'options': [
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex6_2',
            'type': 'translation',
            'order': 1,
            'audio': 'boy',
            'word': 'boy',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "boy"?',
            'options': [
              {'text': 'menino', 'isCorrect': true},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex6_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O garçom serve"',
            'words': ['garçom', 'O', 'serve'],
            'correctOrder': ['O', 'garçom', 'serve'],
          },
          {
            'id': 'ex6_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },

      // SEÇÃO 3 - AVANÇADO
      'mock_course_id_7': {
        'id': '7',
        'courseId': 'mock_course_id',
        'title': 'Lição 7 - Frases Complexas',
        'description': 'Aprenda frases mais complexas',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex7_1',
            'type': 'image',
            'order': 0,
            'question': 'Selecione a imagem do "garçom"',
            'options': [
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex7_2',
            'type': 'translation',
            'order': 1,
            'audio': 'waiter',
            'word': 'waiter',
            'image': AppAssets.lessonWaiter,
            'question': 'Qual é a tradução de "waiter"?',
            'options': [
              {'text': 'garçom', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex7_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O menino e a menina brincam"',
            'words': ['menino', 'O', 'e', 'a', 'menina', 'brincam'],
            'correctOrder': ['O', 'menino', 'e', 'a', 'menina', 'brincam'],
          },
          {
            'id': 'ex7_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'waiter', 'text': 'garçom'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
            ],
          },
        ],
      },
      'mock_course_id_8': {
        'id': '8',
        'courseId': 'mock_course_id',
        'title': 'Lição 8 - Conversação',
        'description': 'Pratique conversação',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex8_1',
            'type': 'image',
            'order': 0,
            'question': 'Selecione a imagem da "menina"',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex8_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex8_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina gosta do cachorro"',
            'words': ['menina', 'A', 'gosta', 'do', 'cachorro'],
            'correctOrder': ['A', 'menina', 'gosta', 'do', 'cachorro'],
          },
          {
            'id': 'ex8_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_9': {
        'id': '9',
        'courseId': 'mock_course_id',
        'title': 'Lição 9 - Teste Final',
        'description': 'Teste final de conhecimento',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex9_1',
            'type': 'image',
            'order': 0,
            'question': 'Selecione a imagem do "menino"',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex9_2',
            'type': 'translation',
            'order': 1,
            'audio': 'dog',
            'word': 'dog',
            'image': AppAssets.lessonDog,
            'question': 'Qual é a tradução de "dog"?',
            'options': [
              {'text': 'cachorro', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex9_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O cachorro e o menino correm"',
            'words': ['cachorro', 'O', 'e', 'o', 'menino', 'correm'],
            'correctOrder': ['O', 'cachorro', 'e', 'o', 'menino', 'correm'],
          },
          {
            'id': 'ex9_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },

      // UNIDADE 2 - LIÇÕES 10-18
      'mock_course_id_10': {
        'id': '10',
        'courseId': 'mock_course_id',
        'title': 'Lição 10 - Números',
        'description': 'Aprenda números básicos',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex10_1',
            'type': 'image',
            'order': 0,
            'audio': 'boy',
            'word': 'boy',
            'question': 'Selecione a imagem de "boy" (menino)',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex10_2',
            'type': 'translation',
            'order': 1,
            'audio': 'one',
            'word': 'one',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "one"?',
            'options': [
              {'text': 'um', 'isCorrect': true},
              {'text': 'dois', 'isCorrect': false},
              {'text': 'três', 'isCorrect': false},
              {'text': 'quatro', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex10_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "Um menino"',
            'words': ['menino', 'Um'],
            'correctOrder': ['Um', 'menino'],
          },
          {
            'id': 'ex10_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'one', 'text': 'um'},
              {'audio': 'two', 'text': 'dois'},
              {'audio': 'three', 'text': 'três'},
              {'audio': 'four', 'text': 'quatro'},
            ],
          },
        ],
      },
      'mock_course_id_11': {
        'id': '11',
        'courseId': 'mock_course_id',
        'title': 'Lição 11 - Cores',
        'description': 'Aprenda nomes de cores',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex11_1',
            'type': 'image',
            'order': 0,
            'audio': 'girl',
            'word': 'girl',
            'question': 'Selecione a imagem de "girl" (menina)',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex11_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex11_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina corre"',
            'words': ['menina', 'A', 'corre'],
            'correctOrder': ['A', 'menina', 'corre'],
          },
          {
            'id': 'ex11_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_12': {
        'id': '12',
        'courseId': 'mock_course_id',
        'title': 'Lição 12 - Comida',
        'description': 'Aprenda nomes de alimentos',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex12_1',
            'type': 'image',
            'order': 0,
            'audio': 'dog',
            'word': 'dog',
            'question': 'Selecione a imagem de "dog" (cachorro)',
            'options': [
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex12_2',
            'type': 'translation',
            'order': 1,
            'audio': 'dog',
            'word': 'dog',
            'image': AppAssets.lessonDog,
            'question': 'Qual é a tradução de "dog"?',
            'options': [
              {'text': 'cachorro', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex12_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O cachorro late"',
            'words': ['cachorro', 'O', 'late'],
            'correctOrder': ['O', 'cachorro', 'late'],
          },
          {
            'id': 'ex12_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_13': {
        'id': '13',
        'courseId': 'mock_course_id',
        'title': 'Lição 13 - Família',
        'description': 'Aprenda membros da família',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex13_1',
            'type': 'image',
            'order': 0,
            'audio': 'waiter',
            'word': 'waiter',
            'question': 'Selecione a imagem de "waiter" (garçom)',
            'options': [
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex13_2',
            'type': 'translation',
            'order': 1,
            'audio': 'waiter',
            'word': 'waiter',
            'image': AppAssets.lessonWaiter,
            'question': 'Qual é a tradução de "waiter"?',
            'options': [
              {'text': 'garçom', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex13_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O garçom serve"',
            'words': ['garçom', 'O', 'serve'],
            'correctOrder': ['O', 'garçom', 'serve'],
          },
          {
            'id': 'ex13_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'waiter', 'text': 'garçom'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
            ],
          },
        ],
      },
      'mock_course_id_14': {
        'id': '14',
        'courseId': 'mock_course_id',
        'title': 'Lição 14 - Casa',
        'description': 'Aprenda partes da casa',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex14_1',
            'type': 'image',
            'order': 0,
            'audio': 'boy',
            'word': 'boy',
            'question': 'Selecione a imagem de "boy" (menino)',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex14_2',
            'type': 'translation',
            'order': 1,
            'audio': 'boy',
            'word': 'boy',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "boy"?',
            'options': [
              {'text': 'menino', 'isCorrect': true},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex14_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O menino brinca"',
            'words': ['menino', 'O', 'brinca'],
            'correctOrder': ['O', 'menino', 'brinca'],
          },
          {
            'id': 'ex14_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_15': {
        'id': '15',
        'courseId': 'mock_course_id',
        'title': 'Lição 15 - Tempo',
        'description': 'Aprenda sobre tempo',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex15_1',
            'type': 'image',
            'order': 0,
            'audio': 'girl',
            'word': 'girl',
            'question': 'Selecione a imagem de "girl" (menina)',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex15_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex15_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina estuda"',
            'words': ['menina', 'A', 'estuda'],
            'correctOrder': ['A', 'menina', 'estuda'],
          },
          {
            'id': 'ex15_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_16': {
        'id': '16',
        'courseId': 'mock_course_id',
        'title': 'Lição 16 - Revisão',
        'description': 'Revise tudo que aprendeu',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex16_1',
            'type': 'image',
            'order': 0,
            'audio': 'dog',
            'word': 'dog',
            'question': 'Selecione a imagem de "dog" (cachorro)',
            'options': [
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex16_2',
            'type': 'translation',
            'order': 1,
            'audio': 'dog',
            'word': 'dog',
            'image': AppAssets.lessonDog,
            'question': 'Qual é a tradução de "dog"?',
            'options': [
              {'text': 'cachorro', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex16_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O cachorro corre"',
            'words': ['cachorro', 'O', 'corre'],
            'correctOrder': ['O', 'cachorro', 'corre'],
          },
          {
            'id': 'ex16_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_17': {
        'id': '17',
        'courseId': 'mock_course_id',
        'title': 'Lição 17 - Conversação',
        'description': 'Pratique conversação',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex17_1',
            'type': 'image',
            'order': 0,
            'audio': 'waiter',
            'word': 'waiter',
            'question': 'Selecione a imagem de "waiter" (garçom)',
            'options': [
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex17_2',
            'type': 'translation',
            'order': 1,
            'audio': 'waiter',
            'word': 'waiter',
            'image': AppAssets.lessonWaiter,
            'question': 'Qual é a tradução de "waiter"?',
            'options': [
              {'text': 'garçom', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex17_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O garçom trabalha"',
            'words': ['garçom', 'O', 'trabalha'],
            'correctOrder': ['O', 'garçom', 'trabalha'],
          },
          {
            'id': 'ex17_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'waiter', 'text': 'garçom'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
            ],
          },
        ],
      },
      'mock_course_id_18': {
        'id': '18',
        'courseId': 'mock_course_id',
        'title': 'Lição 18 - Teste Final',
        'description': 'Teste final da unidade',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex18_1',
            'type': 'image',
            'order': 0,
            'audio': 'boy',
            'word': 'boy',
            'question': 'Selecione a imagem de "boy" (menino)',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex18_2',
            'type': 'translation',
            'order': 1,
            'audio': 'boy',
            'word': 'boy',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "boy"?',
            'options': [
              {'text': 'menino', 'isCorrect': true},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex18_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O menino e a menina"',
            'words': ['menino', 'O', 'e', 'a', 'menina'],
            'correctOrder': ['O', 'menino', 'e', 'a', 'menina'],
          },
          {
            'id': 'ex18_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      
      // UNIDADE 3 - LIÇÕES 19-27
      'mock_course_id_19': {
        'id': '19',
        'courseId': 'mock_course_id',
        'title': 'Lição 19 - Avançado 1',
        'description': 'Conteúdo avançado',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex19_1',
            'type': 'image',
            'order': 0,
            'audio': 'girl',
            'word': 'girl',
            'question': 'Selecione a imagem de "girl" (menina)',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex19_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex19_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina feliz"',
            'words': ['menina', 'A', 'feliz'],
            'correctOrder': ['A', 'menina', 'feliz'],
          },
          {
            'id': 'ex19_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_20': {
        'id': '20',
        'courseId': 'mock_course_id',
        'title': 'Lição 20 - Avançado 2',
        'description': 'Conteúdo avançado',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex20_1',
            'type': 'image',
            'order': 0,
            'audio': 'dog',
            'word': 'dog',
            'question': 'Selecione a imagem de "dog" (cachorro)',
            'options': [
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex20_2',
            'type': 'translation',
            'order': 1,
            'audio': 'dog',
            'word': 'dog',
            'image': AppAssets.lessonDog,
            'question': 'Qual é a tradução de "dog"?',
            'options': [
              {'text': 'cachorro', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex20_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O cachorro grande"',
            'words': ['cachorro', 'O', 'grande'],
            'correctOrder': ['O', 'cachorro', 'grande'],
          },
          {
            'id': 'ex20_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_21': {
        'id': '21',
        'courseId': 'mock_course_id',
        'title': 'Lição 21 - Avançado 3',
        'description': 'Conteúdo avançado',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex21_1',
            'type': 'image',
            'order': 0,
            'audio': 'waiter',
            'word': 'waiter',
            'question': 'Selecione a imagem de "waiter" (garçom)',
            'options': [
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex21_2',
            'type': 'translation',
            'order': 1,
            'audio': 'waiter',
            'word': 'waiter',
            'image': AppAssets.lessonWaiter,
            'question': 'Qual é a tradução de "waiter"?',
            'options': [
              {'text': 'garçom', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex21_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O garçom atende"',
            'words': ['garçom', 'O', 'atende'],
            'correctOrder': ['O', 'garçom', 'atende'],
          },
          {
            'id': 'ex21_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'waiter', 'text': 'garçom'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
            ],
          },
        ],
      },
      'mock_course_id_22': {
        'id': '22',
        'courseId': 'mock_course_id',
        'title': 'Lição 22 - Revisão',
        'description': 'Revisão do conteúdo',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex22_1',
            'type': 'image',
            'order': 0,
            'audio': 'boy',
            'word': 'boy',
            'question': 'Selecione a imagem de "boy" (menino)',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex22_2',
            'type': 'translation',
            'order': 1,
            'audio': 'boy',
            'word': 'boy',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "boy"?',
            'options': [
              {'text': 'menino', 'isCorrect': true},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex22_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O menino joga"',
            'words': ['menino', 'O', 'joga'],
            'correctOrder': ['O', 'menino', 'joga'],
          },
          {
            'id': 'ex22_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_23': {
        'id': '23',
        'courseId': 'mock_course_id',
        'title': 'Lição 23 - Conversação',
        'description': 'Pratique conversação',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex23_1',
            'type': 'image',
            'order': 0,
            'audio': 'girl',
            'word': 'girl',
            'question': 'Selecione a imagem de "girl" (menina)',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex23_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex23_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina dança"',
            'words': ['menina', 'A', 'dança'],
            'correctOrder': ['A', 'menina', 'dança'],
          },
          {
            'id': 'ex23_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_24': {
        'id': '24',
        'courseId': 'mock_course_id',
        'title': 'Lição 24 - Frases',
        'description': 'Construa frases',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex24_1',
            'type': 'image',
            'order': 0,
            'audio': 'dog',
            'word': 'dog',
            'question': 'Selecione a imagem de "dog" (cachorro)',
            'options': [
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex24_2',
            'type': 'translation',
            'order': 1,
            'audio': 'dog',
            'word': 'dog',
            'image': AppAssets.lessonDog,
            'question': 'Qual é a tradução de "dog"?',
            'options': [
              {'text': 'cachorro', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex24_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O cachorro brinca"',
            'words': ['cachorro', 'O', 'brinca'],
            'correctOrder': ['O', 'cachorro', 'brinca'],
          },
          {
            'id': 'ex24_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_25': {
        'id': '25',
        'courseId': 'mock_course_id',
        'title': 'Lição 25 - Diálogos',
        'description': 'Pratique diálogos',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex25_1',
            'type': 'image',
            'order': 0,
            'audio': 'waiter',
            'word': 'waiter',
            'question': 'Selecione a imagem de "waiter" (garçom)',
            'options': [
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex25_2',
            'type': 'translation',
            'order': 1,
            'audio': 'waiter',
            'word': 'waiter',
            'image': AppAssets.lessonWaiter,
            'question': 'Qual é a tradução de "waiter"?',
            'options': [
              {'text': 'garçom', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex25_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O garçom sorri"',
            'words': ['garçom', 'O', 'sorri'],
            'correctOrder': ['O', 'garçom', 'sorri'],
          },
          {
            'id': 'ex25_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'waiter', 'text': 'garçom'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
            ],
          },
        ],
      },
      'mock_course_id_26': {
        'id': '26',
        'courseId': 'mock_course_id',
        'title': 'Lição 26 - Revisão Final',
        'description': 'Revisão final',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex26_1',
            'type': 'image',
            'order': 0,
            'audio': 'boy',
            'word': 'boy',
            'question': 'Selecione a imagem de "boy" (menino)',
            'options': [
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': true},
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex26_2',
            'type': 'translation',
            'order': 1,
            'audio': 'boy',
            'word': 'boy',
            'image': AppAssets.lessonBoy,
            'question': 'Qual é a tradução de "boy"?',
            'options': [
              {'text': 'menino', 'isCorrect': true},
              {'text': 'menina', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex26_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "O menino e o cachorro"',
            'words': ['menino', 'O', 'e', 'o', 'cachorro'],
            'correctOrder': ['O', 'menino', 'e', 'o', 'cachorro'],
          },
          {
            'id': 'ex26_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
      'mock_course_id_27': {
        'id': '27',
        'courseId': 'mock_course_id',
        'title': 'Lição 27 - Teste Final',
        'description': 'Teste final da unidade',
        'xpReward': 10,
        'gemsReward': 1,
        'isLocked': true,
        'exercises': [
          {
            'id': 'ex27_1',
            'type': 'image',
            'order': 0,
            'audio': 'girl',
            'word': 'girl',
            'question': 'Selecione a imagem de "girl" (menina)',
            'options': [
              {'id': 'girl', 'image': AppAssets.lessonGirl, 'isCorrect': true},
              {'id': 'boy', 'image': AppAssets.lessonBoy, 'isCorrect': false},
              {'id': 'dog', 'image': AppAssets.lessonDog, 'isCorrect': false},
              {'id': 'waiter', 'image': AppAssets.lessonWaiter, 'isCorrect': false},
            ],
          },
          {
            'id': 'ex27_2',
            'type': 'translation',
            'order': 1,
            'audio': 'girl',
            'word': 'girl',
            'image': AppAssets.lessonGirl,
            'question': 'Qual é a tradução de "girl"?',
            'options': [
              {'text': 'menina', 'isCorrect': true},
              {'text': 'menino', 'isCorrect': false},
              {'text': 'cachorro', 'isCorrect': false},
              {'text': 'garçom', 'isCorrect': false},
            ],
          },
          {
            'id': 'ex27_3',
            'type': 'word_order',
            'order': 2,
            'question': 'Organize as palavras: "A menina e o garçom"',
            'words': ['menina', 'A', 'e', 'o', 'garçom'],
            'correctOrder': ['A', 'menina', 'e', 'o', 'garçom'],
          },
          {
            'id': 'ex27_4',
            'type': 'match',
            'order': 3,
            'question': 'Combine as palavras com suas traduções',
            'pairs': [
              {'audio': 'girl', 'text': 'menina'},
              {'audio': 'boy', 'text': 'menino'},
              {'audio': 'dog', 'text': 'cachorro'},
              {'audio': 'waiter', 'text': 'garçom'},
            ],
          },
        ],
      },
    };
  }
}

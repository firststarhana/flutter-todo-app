class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      'appTitle': '할 일 목록',
      'addTodo': '할 일 추가',
      'editTodo': '할 일 수정',
      'settings': '설정',
      'title': '제목',
      'attachImage': '이미지 첨부',
      'save': '저장',
      'language': '언어',
      'theme': '테마 색상',
      'emptyTodoMessage': '할 일이 없습니다. 추가해주세요!',
      'increaseFont': '글자 크게',
      'decreaseFont': '글자 작게',
    },
    'en': {
      'appTitle': 'Todo List',
      'addTodo': 'Add Todo',
      'editTodo': 'Edit Todo',
      'settings': 'Settings',
      'title': 'Title',
      'attachImage': 'Attach Image',
      'save': 'Save',
      'language': 'Language',
      'theme': 'Theme Color',
      'emptyTodoMessage': 'No todos yet. Add some!',
      'increaseFont': 'Increase Font Size',
      'decreaseFont': 'Decrease Font Size',
    },
  };

  static String getText(String key, String languageCode) {
    // 1. 요청된 언어의 번역이 있는지 확인
    final translations = _localizedValues[languageCode];
    if (translations != null && translations.containsKey(key)) {
      return translations[key]!;
    }
    
    // 2. 영어 번역이 있는지 확인
    final englishTranslations = _localizedValues['en'];
    if (englishTranslations != null && englishTranslations.containsKey(key)) {
      return englishTranslations[key]!;
    }
    
    // 3. 모든 경우에 대한 대비책
    return key;  // 번역을 찾지 못한 경우 키 자체를 반환
  }
}

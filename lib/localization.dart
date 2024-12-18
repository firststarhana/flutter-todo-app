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
      'createdDate': '최초로 작성한 날짜:',
      'modifiedDate': '마지막 수정:',
      'elapsed': '작성한지 {duration} 경과',
      'just_now': '방금전',
      'year': '년',
      'month': '개월',
      'day': '일',
      'hour': '시간',
      'minute': '분',
      'second': '초',
      'delete': '삭제',
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
      'createdDate': 'Created on:',
      'modifiedDate': 'Last modified:',
      'elapsed': 'Elapsed since creation: {duration}',
      'just_now': 'Just now',
      'year': 'year',
      'month': 'month',
      'day': 'day',
      'hour': 'hour',
      'minute': 'minute',
      'second': 'second',
      'delete': 'Delete',
    },
  };

  static String getText(String key, String languageCode, {Map<String, String>? params}) {
    // 요청된 언어의 번역이 있는지 확인
    final translations = _localizedValues[languageCode];
    String? text;
    if (translations != null && translations.containsKey(key)) {
      text = translations[key]!;
    }

    // 영어 번역이 있는지 확인
    if (text == null) {
      final englishTranslations = _localizedValues['en'];
      if (englishTranslations != null && englishTranslations.containsKey(key)) {
        text = englishTranslations[key]!;
      }
    }

    // 모든 경우에 대한 대비책
    if (text == null) return key;

    // 파라미터가 있는 경우 대체
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text!.replaceAll('{$paramKey}', paramValue);
      });
    }

    return text!;
  }
}

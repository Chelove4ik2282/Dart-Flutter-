class WordCard {
  final String mainWord;
  final List<String> tabooWords;

  WordCard({required this.mainWord, required this.tabooWords});

  factory WordCard.fromJson(Map<String, dynamic> json) => WordCard(
        mainWord: json['main'],
        tabooWords: List<String>.from(json['taboo']),
      );
}
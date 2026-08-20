class Outfit {
  final String id;
  final String name;
  final String description;
  final String? outfitImageUrl;

  Outfit({
    required this.id,
    required this.name,
    required this.description,
    this.outfitImageUrl,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        outfitImageUrl: json['outfitImageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'outfitImageUrl': outfitImageUrl,
      };
}

class Character {
  final String id;
  final String name;
  final List<String> faceReferenceUrls;
  final String activeOutfitId;
  final List<Outfit> closet;
  final String defaultStylePrompt;

  Character({
    required this.id,
    required this.name,
    required this.faceReferenceUrls,
    required this.activeOutfitId,
    required this.closet,
    this.defaultStylePrompt = '',
  });

  Outfit get activeOutfit => closet.firstWhere(
        (o) => o.id == activeOutfitId,
        orElse: () => closet.first,
      );

  Character copyWith({
    String? id,
    String? name,
    List<String>? faceReferenceUrls,
    String? activeOutfitId,
    List<Outfit>? closet,
    String? defaultStylePrompt,
  }) => Character(
        id: id ?? this.id,
        name: name ?? this.name,
        faceReferenceUrls: faceReferenceUrls ?? this.faceReferenceUrls,
        activeOutfitId: activeOutfitId ?? this.activeOutfitId,
        closet: closet ?? this.closet,
        defaultStylePrompt: defaultStylePrompt ?? this.defaultStylePrompt,
      );

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'],
        name: json['name'],
        faceReferenceUrls: List<String>.from(json['faceReferenceUrls']),
        activeOutfitId: json['activeOutfitId'],
        defaultStylePrompt: json['defaultStylePrompt'] ?? '',
        closet: (json['closet'] as List).map((o) => Outfit.fromJson(o)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'faceReferenceUrls': faceReferenceUrls,
        'activeOutfitId': activeOutfitId,
        'defaultStylePrompt': defaultStylePrompt,
        'closet': closet.map((o) => o.toJson()).toList(),
      };
}

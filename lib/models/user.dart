
class User {
  final int index;
  final String about;
  final String name;
  final String email;
  final String picture;

  User({required this.index, required this.about, required this.name,required this.email, required this.picture});

  @override
  String toString() {
    return 'User{index: $index, about: $about, name: $name, email: $email, picture: $picture}';
  }

  Map<String, dynamic> toJson() {
    return {
      "index": this.index,
      "about": this.about,
      "name": this.name,
      "email": this.email,
      "picture": this.picture,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      index: int.parse(json["index"]),
      about: json["about"],
      name: json["name"],
      email: json["email"],
      picture: json["picture"],
    );
  }

}
class Teacher {
  String? id;
  String name;
  String email;
  String phoneNumber;

  Teacher(
    this.name,
    this.email,
    this.phoneNumber,
  );

  Teacher.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        email = map['email'],
        phoneNumber = map['phone_number'];

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}

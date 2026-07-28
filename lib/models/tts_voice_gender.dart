enum TtsVoiceGender {
  female,
  male;

  static TtsVoiceGender fromJson(Object? value) {
    if (value == male.name) {
      return male;
    }
    return female;
  }

  String toJson() => name;
}

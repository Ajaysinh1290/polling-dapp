class Validators {
  static String? emptyTextValidator(String? text) {
    if(text == null || text.trim().isEmpty) {
      return "This Field is Required *";
    }
    return null;
  }
}
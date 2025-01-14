import 'package:iskole/core/modal/user.dart';

class UserInstance {
  static AppUser? appUser;

  static void clear(){
    appUser = null;
  }

  static void setUser({
    required id,
    required firstName,
    required phoneNumber,
    lastName = "",
    required role,
    required birthday,
    required district,
    required school,
    isActivated = false
  }) {
    appUser = AppUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
      birthday: birthday,
      district: district,
      school: school,
      isActivated:isActivated??false
    );
  }
}

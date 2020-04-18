import 'package:get_it/get_it.dart';
import 'package:uproplus/core/services/user_service.dart';

import 'core/viewmodels/login_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => UserService(userPool));

  locator.registerFactory(() => LoginModel());
}

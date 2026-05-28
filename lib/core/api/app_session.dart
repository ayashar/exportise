import 'package:flutter/foundation.dart';

import 'api_models.dart';

class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  ApiUser? currentUser;
  AuthTokens? tokens;

  bool get isAuthenticated => tokens != null;

  String get displayName {
    final user = currentUser;
    if (user == null) {
      return 'Exportise';
    }

    return user.companyName.isEmpty ? user.fullName : user.companyName;
  }

  Map<String, String> get authHeaders {
    final accessToken = tokens?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return const {};
    }

    return {'Authorization': 'Bearer $accessToken'};
  }

  void setSession({required ApiUser user, required AuthTokens tokens}) {
    currentUser = user;
    this.tokens = tokens;
    notifyListeners();
  }

  void setUser(ApiUser user) {
    currentUser = user;
    notifyListeners();
  }

  void clear() {
    currentUser = null;
    tokens = null;
    notifyListeners();
  }
}

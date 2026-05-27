import 'api_client.dart';
import 'api_models.dart';
import 'app_session.dart';

class ApiRepository {
  ApiRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Map<String, String> get _headers => AppSession.instance.authHeaders;

  Future<ApiUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );

    final tokens = AuthTokens.fromJson(_asMap(json));
    AppSession.instance.tokens = tokens;

    final user = await me();
    AppSession.instance.setSession(user: user, tokens: tokens);
    return user;
  }

  Future<ApiUser> register({
    required String companyName,
    required String email,
    required String fullName,
    required String password,
    required String phone,
  }) async {
    final json = await _client.postJson(
      '/api/auth/register',
      body: {
        'company_name': companyName,
        'email': email,
        'full_name': fullName,
        'password': password,
        'phone': phone,
      },
    );

    return ApiUser.fromJson(_asMap(json));
  }

  Future<void> logout() async {
    final refreshToken = AppSession.instance.tokens?.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _client.postJson(
        '/api/auth/logout',
        headers: _headers,
        body: {'refresh_token': refreshToken},
      );
    }

    AppSession.instance.clear();
  }

  Future<ApiUser> me() async {
    final json = await _client.getJson('/api/auth/me', headers: _headers);
    return ApiUser.fromJson(_asMap(json));
  }

  Future<List<AnalysisProduct>> listAnalysisProducts() async {
    final json = await _client.getJson(
      '/api/analys_products/',
      headers: _headers,
    );
    return _asList(
      json,
    ).map((item) => AnalysisProduct.fromJson(_asMap(item))).toList();
  }

  Future<AnalysisProduct> createAnalysisProduct({
    required String category,
    required String description,
    required String productName,
  }) async {
    final json = await _client.postJson(
      '/api/analys_products/',
      headers: _headers,
      body: {
        'category': category,
        'description': description,
        'product_name': productName,
      },
    );

    return AnalysisProduct.fromJson(_asMap(json));
  }

  Future<AnalysisProduct> getAnalysisProduct(int analysProductId) async {
    final json = await _client.getJson(
      '/api/analys_products/$analysProductId',
      headers: _headers,
    );

    return AnalysisProduct.fromJson(_asMap(json));
  }

  Future<void> deleteAnalysisProduct(int analysProductId) async {
    await _client.deleteJson(
      '/api/analys_products/$analysProductId',
      headers: _headers,
    );
  }

  Future<List<DesignReference>> listDesignReferences(
    int analysProductId,
  ) async {
    final json = await _client.getJson(
      '/api/analys_products/$analysProductId/design-references',
      headers: _headers,
    );

    return _asList(
      json,
    ).map((item) => DesignReference.fromJson(_asMap(item))).toList();
  }

  Future<DesignReference> createDesignReference({
    required int analysProductId,
    required String description,
    required String imageUrl,
    required List<String> tags,
    required String title,
    int sortOrder = 0,
  }) async {
    final json = await _client.postJson(
      '/api/analys_products/$analysProductId/design-references',
      headers: _headers,
      body: {
        'description': description,
        'image_url': imageUrl,
        'sort_order': sortOrder,
        'tags': tags,
        'title': title,
      },
    );

    return DesignReference.fromJson(_asMap(json));
  }

  Future<Map<String, dynamic>> analyzeProduct(int productId) async {
    final json = await _client.postJson(
      '/api/reviews/$productId/analyze',
      headers: _headers,
    );

    return _asMap(json);
  }

  Future<List<ChatSession>> listChatSessions() async {
    final json = await _client.getJson('/api/chat/sessions', headers: _headers);
    return _asList(
      json,
    ).map((item) => ChatSession.fromJson(_asMap(item))).toList();
  }

  Future<ChatSession> createChatSession({
    required String title,
    int? productId,
  }) async {
    final json = await _client.postJson(
      '/api/chat/sessions',
      headers: _headers,
      body: {'title': title, 'product_id': productId},
    );

    return ChatSession.fromJson(_asMap(json));
  }

  Future<List<ChatMessage>> listMessages(int sessionId) async {
    final json = await _client.getJson(
      '/api/chat/sessions/$sessionId/messages',
      headers: _headers,
    );

    return _asList(
      json,
    ).map((item) => ChatMessage.fromJson(_asMap(item))).toList();
  }

  Future<ChatReply> sendMessage({
    required int sessionId,
    required String message,
    int? analysProductId,
    int? designReferenceId,
  }) async {
    final body = <String, dynamic>{'message': message};
    if (analysProductId != null) {
      body['analys_product_id'] = analysProductId;
    }
    if (designReferenceId != null) {
      body['design_reference_id'] = designReferenceId;
    }

    final json = await _client.postJson(
      '/api/chat/sessions/$sessionId/send',
      headers: _headers,
      body: body,
    );

    return ChatReply.fromJson(_asMap(json));
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((dynamic key, dynamic entry) {
      return MapEntry(key.toString(), entry);
    });
  }

  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }

  return const [];
}

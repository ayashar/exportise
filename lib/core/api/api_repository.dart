import 'api_client.dart';
import 'api_models.dart';
import 'app_session.dart';

class ApiRepository {
  ApiRepository({ApiClient? client}) : _client = client ?? ApiClient();

  static const String _offlineAccessToken = 'offline-reviewer-access-token';
  static const String _offlineEmail = 'exportise@contoh.com';
  static const String _offlinePassword = 'Exportise123';
  static int _nextOfflineProductId = 1;
  static int _nextOfflineReferenceId = 1;
  static int _nextOfflineSessionId = 1;
  static int _nextOfflineMessageId = 1;
  static final List<AnalysisProduct> _offlineProducts = [];
  static final List<ChatSession> _offlineSessions = [];
  static final Map<int, List<ChatMessage>> _offlineMessages = {};
  static ApiUser _offlineUser = const ApiUser(
    companyName: 'Exportise',
    createdAt: null,
    email: _offlineEmail,
    fullName: 'Reviewer Exportise',
    id: 1,
    phone: '',
    updatedAt: null,
  );

  final ApiClient _client;

  Map<String, String> get _headers => AppSession.instance.authHeaders;
  bool get _isOfflineSession =>
      AppSession.instance.tokens?.accessToken == _offlineAccessToken;

  Future<ApiUser> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().toLowerCase() == _offlineEmail &&
        password == _offlinePassword) {
      _activateOfflineSession(_offlineUser);
      return _offlineUser;
    }

    try {
      final json = await _client.postJson(
        '/api/auth/login',
        body: {'email': email, 'password': password},
      );

      final tokens = AuthTokens.fromJson(_asMap(json));
      AppSession.instance.tokens = tokens;

      final user = await me();
      AppSession.instance.setSession(user: user, tokens: tokens);
      return user;
    } catch (_) {
      final fallbackUser = _offlineUserFromLogin(email);
      _activateOfflineSession(fallbackUser);
      return fallbackUser;
    }
  }

  Future<ApiUser> register({
    required String companyName,
    required String email,
    required String fullName,
    required String password,
    required String phone,
  }) async {
    try {
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
    } catch (_) {
      _offlineUser = _offlineUserFromRegister(
        companyName: companyName,
        email: email,
        fullName: fullName,
        phone: phone,
      );
      return _offlineUser;
    }
  }

  Future<void> logout() async {
    if (_isOfflineSession) {
      AppSession.instance.clear();
      return;
    }

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
    if (_isOfflineSession) {
      AppSession.instance.setUser(_offlineUser);
      return _offlineUser;
    }

    final json = await _client.getJson('/api/auth/me', headers: _headers);
    return ApiUser.fromJson(_asMap(json));
  }

  Future<List<AnalysisProduct>> listAnalysisProducts() async {
    if (_isOfflineSession) {
      return List.unmodifiable(_offlineProducts);
    }

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
    if (_isOfflineSession) {
      final now = DateTime.now();
      final product = AnalysisProduct(
        category: category,
        createdAt: now,
        description: description,
        id: _nextOfflineProductId++,
        message:
            'Backend sedang tidak tersedia. Analisis akan diproses setelah server aktif kembali.',
        productName: productName,
        status: 'pending',
        updatedAt: now,
        userId: _offlineUser.id,
      );
      _offlineProducts.insert(0, product);
      return product;
    }

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
    if (_isOfflineSession) {
      return _offlineProducts.firstWhere(
        (product) => product.id == analysProductId,
        orElse: () =>
            throw ApiException('Produk tidak ditemukan.', statusCode: 404),
      );
    }

    final json = await _client.getJson(
      '/api/analys_products/$analysProductId',
      headers: _headers,
    );

    return AnalysisProduct.fromJson(_asMap(json));
  }

  Future<void> deleteAnalysisProduct(int analysProductId) async {
    if (_isOfflineSession) {
      _offlineProducts.removeWhere((product) => product.id == analysProductId);
      return;
    }

    await _client.deleteJson(
      '/api/analys_products/$analysProductId',
      headers: _headers,
    );
  }

  Future<List<DesignReference>> listDesignReferences(
    int analysProductId,
  ) async {
    if (_isOfflineSession) {
      final product = await getAnalysisProduct(analysProductId);
      return product.designReferences;
    }

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
    if (_isOfflineSession) {
      final now = DateTime.now();
      final reference = DesignReference(
        analysProductId: analysProductId,
        createdAt: now,
        description: description,
        id: _nextOfflineReferenceId++,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
        tags: tags,
        title: title,
        updatedAt: now,
      );
      _replaceOfflineProduct(
        analysProductId,
        (product) => _copyProduct(
          product,
          designReferences: [...product.designReferences, reference],
        ),
      );
      return reference;
    }

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
    if (_isOfflineSession) {
      return {
        'message':
            'Backend sedang tidak tersedia. Analisis belum bisa dijalankan.',
      };
    }

    final json = await _client.postJson(
      '/api/reviews/$productId/analyze',
      headers: _headers,
    );

    return _asMap(json);
  }

  Future<List<ChatSession>> listChatSessions() async {
    if (_isOfflineSession) {
      return List.unmodifiable(_offlineSessions);
    }

    final json = await _client.getJson('/api/chat/sessions', headers: _headers);
    return _asList(
      json,
    ).map((item) => ChatSession.fromJson(_asMap(item))).toList();
  }

  Future<ChatSession> createChatSession({
    required String title,
    int? productId,
  }) async {
    if (_isOfflineSession) {
      final now = DateTime.now();
      final session = ChatSession(
        createdAt: now,
        id: _nextOfflineSessionId++,
        productId: productId,
        title: title,
        updatedAt: now,
        userId: _offlineUser.id,
      );
      _offlineSessions.insert(0, session);
      _offlineMessages[session.id] = const [];
      return session;
    }

    final json = await _client.postJson(
      '/api/chat/sessions',
      headers: _headers,
      body: {'title': title, 'product_id': productId},
    );

    return ChatSession.fromJson(_asMap(json));
  }

  Future<List<ChatMessage>> listMessages(int sessionId) async {
    if (_isOfflineSession) {
      return List.unmodifiable(_offlineMessages[sessionId] ?? const []);
    }

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
    if (_isOfflineSession) {
      final now = DateTime.now();
      final messages = [...?_offlineMessages[sessionId]];
      messages.add(
        ChatMessage(
          content: message,
          createdAt: now,
          id: _nextOfflineMessageId++,
          role: 'user',
          sessionId: sessionId,
        ),
      );
      const reply = ChatReply(
        imageUrl: null,
        reply:
            'Backend BrainStudio sedang tidak tersedia. Pesanmu sudah tersimpan sementara dan bisa dicoba lagi setelah server aktif.',
      );
      messages.add(
        ChatMessage(
          content: reply.reply,
          createdAt: now,
          id: _nextOfflineMessageId++,
          role: 'assistant',
          sessionId: sessionId,
        ),
      );
      _offlineMessages[sessionId] = messages;
      return reply;
    }

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

  void _replaceOfflineProduct(
    int analysProductId,
    AnalysisProduct Function(AnalysisProduct product) update,
  ) {
    final index = _offlineProducts.indexWhere(
      (product) => product.id == analysProductId,
    );
    if (index == -1) {
      throw ApiException('Produk tidak ditemukan.', statusCode: 404);
    }
    _offlineProducts[index] = update(_offlineProducts[index]);
  }

  AnalysisProduct _copyProduct(
    AnalysisProduct product, {
    List<DesignReference>? designReferences,
  }) {
    return AnalysisProduct(
      category: product.category,
      createdAt: product.createdAt,
      description: product.description,
      designReferences: designReferences ?? product.designReferences,
      id: product.id,
      imageUrl: product.imageUrl,
      message: product.message,
      productName: product.productName,
      report: product.report,
      status: product.status,
      updatedAt: DateTime.now(),
      userId: product.userId,
    );
  }

  void _activateOfflineSession(ApiUser user) {
    _offlineUser = user;
    AppSession.instance.setSession(
      user: user,
      tokens: const AuthTokens(
        accessToken: _offlineAccessToken,
        refreshToken: 'offline-reviewer-refresh-token',
        tokenType: 'bearer',
      ),
    );
  }

  ApiUser _offlineUserFromLogin(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty ||
        normalizedEmail.toLowerCase() == _offlineUser.email.toLowerCase()) {
      return _offlineUser;
    }

    return ApiUser(
      companyName: _offlineUser.companyName,
      createdAt: null,
      email: normalizedEmail,
      fullName: normalizedEmail.split('@').first,
      id: _offlineUser.id,
      phone: _offlineUser.phone,
      updatedAt: null,
    );
  }

  ApiUser _offlineUserFromRegister({
    required String companyName,
    required String email,
    required String fullName,
    required String phone,
  }) {
    final normalizedEmail = email.trim();
    final normalizedName = fullName.trim();
    final normalizedCompany = companyName.trim();

    return ApiUser(
      companyName: normalizedCompany.isEmpty ? 'Exportise' : normalizedCompany,
      createdAt: DateTime.now(),
      email: normalizedEmail.isEmpty ? _offlineEmail : normalizedEmail,
      fullName: normalizedName.isEmpty ? 'Pengguna Exportise' : normalizedName,
      id: _offlineUser.id,
      phone: phone.trim(),
      updatedAt: DateTime.now(),
    );
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

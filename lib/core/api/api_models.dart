class ApiUser {
  const ApiUser({
    required this.companyName,
    required this.createdAt,
    required this.email,
    required this.fullName,
    required this.id,
    required this.phone,
    required this.updatedAt,
  });

  final String companyName;
  final DateTime? createdAt;
  final String email;
  final String fullName;
  final int id;
  final String phone;
  final DateTime? updatedAt;

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      companyName: _string(json, 'company_name'),
      createdAt: _dateTime(json, 'created_at'),
      email: _string(json, 'email'),
      fullName: _string(json, 'full_name'),
      id: _int(json, 'id'),
      phone: _string(json, 'phone'),
      updatedAt: _dateTime(json, 'updated_at'),
    );
  }
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: _string(json, 'access_token'),
      refreshToken: _string(json, 'refresh_token'),
      tokenType: _string(json, 'token_type'),
    );
  }
}

class AnalysisProduct {
  const AnalysisProduct({
    required this.category,
    required this.createdAt,
    required this.description,
    required this.id,
    required this.message,
    required this.productName,
    required this.status,
    required this.updatedAt,
    this.designReferences = const [],
    this.imageUrl,
    this.report,
    this.userId,
  });

  final String category;
  final DateTime? createdAt;
  final String description;
  final List<DesignReference> designReferences;
  final String? imageUrl;
  final int id;
  final String? message;
  final String productName;
  final Map<String, dynamic>? report;
  final String status;
  final DateTime? updatedAt;
  final int? userId;

  bool get isDone => status.toLowerCase() == 'done';

  bool get isProcessing {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'pending' || lowerStatus == 'processing';
  }

  Map<String, dynamic>? get summary {
    final currentReport = report;
    if (currentReport == null) {
      return null;
    }

    return _mapValue(currentReport, 'summary');
  }

  factory AnalysisProduct.fromJson(Map<String, dynamic> json) {
    return AnalysisProduct(
      category: _string(json, 'category'),
      createdAt: _dateTime(json, 'created_at'),
      description: _string(json, 'description'),
      designReferences: _listValue(
        json,
        'design_references',
      ).map((item) => DesignReference.fromJson(item)).toList(),
      id: _int(json, 'id'),
      imageUrl: _nullableString(json, 'image_url'),
      message: _nullableString(json, 'message'),
      productName: _string(json, 'product_name'),
      report: _mapValue(json, 'report'),
      status: _string(json, 'status'),
      updatedAt: _dateTime(json, 'updated_at'),
      userId: _nullableInt(json, 'user_id'),
    );
  }
}

class DesignReference {
  const DesignReference({
    required this.analysProductId,
    required this.createdAt,
    required this.description,
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
    required this.tags,
    required this.title,
    required this.updatedAt,
  });

  final int analysProductId;
  final DateTime? createdAt;
  final String description;
  final int id;
  final String? imageUrl;
  final int sortOrder;
  final List<String> tags;
  final String title;
  final DateTime? updatedAt;

  factory DesignReference.fromJson(Map<String, dynamic> json) {
    return DesignReference(
      analysProductId: _int(json, 'analys_product_id'),
      createdAt: _dateTime(json, 'created_at'),
      description: _string(json, 'description'),
      id: _int(json, 'id'),
      imageUrl: _nullableString(json, 'image_url'),
      sortOrder: _int(json, 'sort_order'),
      tags: _stringList(json['tags']),
      title: _string(json, 'title'),
      updatedAt: _dateTime(json, 'updated_at'),
    );
  }
}

class ChatSession {
  const ChatSession({
    required this.createdAt,
    required this.id,
    required this.title,
    required this.updatedAt,
    this.productId,
    this.userId,
  });

  final DateTime? createdAt;
  final int id;
  final int? productId;
  final String title;
  final DateTime? updatedAt;
  final int? userId;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      createdAt: _dateTime(json, 'created_at'),
      id: _int(json, 'id'),
      productId: _nullableInt(json, 'product_id'),
      title: _string(json, 'title'),
      updatedAt: _dateTime(json, 'updated_at'),
      userId: _nullableInt(json, 'user_id'),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.content,
    required this.createdAt,
    required this.id,
    required this.role,
    required this.sessionId,
    this.attachmentTitle,
    this.imageUrl,
    this.tokenCount,
  });

  final String? attachmentTitle;
  final String content;
  final DateTime? createdAt;
  final int id;
  final String? imageUrl;
  final String role;
  final int sessionId;
  final int? tokenCount;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: _string(json, 'content'),
      createdAt: _dateTime(json, 'created_at'),
      id: _int(json, 'id'),
      attachmentTitle: _nullableString(json, 'attachment_title'),
      imageUrl: _nullableString(json, 'image_url'),
      role: _string(json, 'role'),
      sessionId: _int(json, 'session_id'),
      tokenCount: _nullableInt(json, 'token_count'),
    );
  }
}

class ChatReply {
  const ChatReply({required this.imageUrl, required this.reply});

  final String? imageUrl;
  final String reply;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    return ChatReply(
      imageUrl: _nullableString(json, 'image_url'),
      reply: _string(json, 'reply'),
    );
  }
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value == null ? '' : value.toString();
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value?.toString();
}

DateTime? _dateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

int _int(Map<String, dynamic> json, String key) {
  return _nullableInt(json, key) ?? 0;
}

int? _nullableInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

Map<String, dynamic>? _mapValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((dynamic mapKey, dynamic mapValue) {
      return MapEntry(mapKey.toString(), mapValue);
    });
  }

  return null;
}

List<dynamic> _listValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) {
    return value;
  }

  return const [];
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return const [];
}

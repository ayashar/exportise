import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_models.dart';
import '../../core/api/api_repository.dart';
import '../../core/api/app_session.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../analysis/analysis_input_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';

enum ChatbotMode { designReference, fresh }

class BrainStudioPage extends StatefulWidget {
  const BrainStudioPage.designReference({super.key})
    : mode = ChatbotMode.designReference;

  const BrainStudioPage.fresh({super.key}) : mode = ChatbotMode.fresh;

  final ChatbotMode mode;

  @override
  State<BrainStudioPage> createState() => _BrainStudioPageState();
}

class _BrainStudioPageState extends State<BrainStudioPage> {
  final _repository = ApiRepository();
  final _composerController = TextEditingController();

  late Future<_BrainData> _brainFuture;
  bool _isSending = false;
  bool _isCreatingSession = false;
  int? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _brainFuture = _loadData();
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<_BrainData>(
              future: _brainFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ChatError(
                    message: _errorMessage(snapshot.error),
                    onRetry: _reload,
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return _ChatError(
                    message: 'Riwayat chat belum tersedia.',
                    onRetry: _reload,
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          children: [
                            _ChatHeader(),
                            const SizedBox(height: 28),
                            _BrainIntro(mode: widget.mode),
                            const SizedBox(height: 20),
                            _SessionRow(
                              isCreatingSession: _isCreatingSession,
                              onCreateSession: _createNewSession,
                              sessions: data.sessions,
                              selectedSessionId:
                                  _selectedSessionId ?? data.activeSession?.id,
                              onSelectSession: _selectSession,
                            ),
                            const SizedBox(height: 20),
                            if (data.activeSession == null)
                              _EmptyChatState(
                                isCreatingSession: _isCreatingSession,
                                mode: widget.mode,
                                onCreateSession: _createNewSession,
                              )
                            else
                              _MessageList(
                                messages: data.messages,
                                mode: widget.mode,
                                activeSession: data.activeSession!,
                              ),
                          ],
                        ),
                      ),
                    ),
                    _ChatComposer(
                      controller: _composerController,
                      isSending: _isSending,
                      onSend: data.activeSession == null
                          ? null
                          : () => _sendMessage(data.activeSession!),
                    ),
                    AppBottomNavigation(
                      selectedTab: AppTab.brains,
                      onTabSelected: (tab) {
                        if (tab == AppTab.home) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                        if (tab == AppTab.analysis) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const AnalysisInputPage(),
                            ),
                          );
                        }
                        if (tab == AppTab.reports) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const HistoryPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<_BrainData> _loadData() async {
    final sessions = await _repository.listChatSessions();

    ChatSession? activeSession;
    if (_selectedSessionId != null) {
      activeSession = sessions
          .where((session) => session.id == _selectedSessionId)
          .cast<ChatSession?>()
          .firstOrNull;
    }

    activeSession ??= _defaultSessionForMode(sessions);

    if (activeSession == null) {
      return _BrainData(
        activeSession: null,
        messages: const [],
        sessions: sessions,
      );
    }

    final messages = await _repository.listMessages(activeSession.id);
    return _BrainData(
      activeSession: activeSession,
      messages: messages,
      sessions: [
        activeSession,
        ...sessions.where((session) => session.id != activeSession!.id),
      ],
    );
  }

  Future<void> _reload() async {
    setState(() {
      _brainFuture = _loadData();
    });
  }

  ChatSession? _defaultSessionForMode(List<ChatSession> sessions) {
    if (sessions.isEmpty) {
      return null;
    }

    final preferred = sessions.where((session) {
      if (widget.mode == ChatbotMode.designReference) {
        return session.productId == 12 ||
            session.title.toLowerCase().contains('tas');
      }

      return session.productId == 13 ||
          session.title.toLowerCase().contains('eco');
    }).firstOrNull;

    return preferred ?? sessions.first;
  }

  Future<void> _selectSession(ChatSession session) async {
    setState(() => _selectedSessionId = session.id);
    await _reload();
  }

  Future<void> _createNewSession() async {
    if (_isCreatingSession) {
      return;
    }

    setState(() => _isCreatingSession = true);

    try {
      final session = await _createSessionInternal();
      setState(() => _selectedSessionId = session.id);
      await _reload();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty ? 'Gagal membuat sesi chat' : error.message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingSession = false);
      }
    }
  }

  Future<ChatSession> _createSessionInternal() {
    return _repository.createChatSession(
      title: widget.mode == ChatbotMode.designReference
          ? 'Diskusi Design Reference'
          : 'Diskusi Baru',
    );
  }

  Future<void> _sendMessage(ChatSession activeSession) async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);

    try {
      await _repository.sendMessage(sessionId: activeSession.id, message: text);
      _composerController.clear();
      await _reload();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty ? 'Pesan gagal dikirim' : error.message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Gagal memuat Brain Studio.';
  }
}

class _ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openProfile(context),
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/home/profile.png'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openProfile(context),
            child: Text(
              AppSession.instance.displayName,
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.neutral09,
              ),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openNotifications(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.system01,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neutral03),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A7A5900),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AppIcon(
                AppIcons.bell(),
                color: AppColors.primary05,
                dimension: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrainIntro extends StatelessWidget {
  const _BrainIntro({required this.mode});

  final ChatbotMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary04,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: AppIcon(
              AppIcons.brain(PhosphorIconsStyle.fill),
              color: AppColors.primary08,
              dimension: 30,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'BrainStudio',
          style: AppTypography.headlineSm.copyWith(color: AppColors.neutral09),
        ),
        const SizedBox(height: 8),
        Text(
          mode == ChatbotMode.designReference
              ? 'Diskusi referensi desain dan pengembangan visual.'
              : 'Asisten AI desain produk untuk\nmenembus pasar internasional.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.isCreatingSession,
    required this.onCreateSession,
    required this.onSelectSession,
    required this.selectedSessionId,
    required this.sessions,
  });

  final bool isCreatingSession;
  final VoidCallback onCreateSession;
  final ValueChanged<ChatSession> onSelectSession;
  final int? selectedSessionId;
  final List<ChatSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Sesi Chat',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.neutral09,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: isCreatingSession ? null : onCreateSession,
              icon: AppIcon(
                AppIcons.addCircle(),
                color: AppColors.primary05,
                dimension: 16,
              ),
              label: Text(isCreatingSession ? 'Membuat...' : 'Baru'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Text(
            'Belum ada sesi chat.',
            style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sessions
                  .map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(session.title),
                        selected: selectedSessionId == session.id,
                        onSelected: (_) => onSelectSession(session),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.activeSession,
    required this.messages,
    required this.mode,
  });

  final ChatSession activeSession;
  final List<ChatMessage> messages;
  final ChatbotMode mode;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyChatState(mode: mode);
    }

    return Column(
      children: messages
          .map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: message.role == 'assistant'
                  ? _AiMessage(
                      attachmentTitle: message.attachmentTitle,
                      imageUrl: message.imageUrl,
                      text: message.content,
                    )
                  : _UserMessage(text: message.content),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({
    this.isCreatingSession = false,
    this.mode = ChatbotMode.fresh,
    this.onCreateSession,
  });

  final bool isCreatingSession;
  final ChatbotMode mode;
  final VoidCallback? onCreateSession;

  @override
  Widget build(BuildContext context) {
    final title = mode == ChatbotMode.designReference
        ? 'Belum ada diskusi referensi desain'
        : 'Belum ada sesi BrainStudio';
    final body = mode == ChatbotMode.designReference
        ? 'Sesi diskusi akan muncul setelah kamu membuka referensi desain dari hasil analisis.'
        : 'Mulai sesi baru saat kamu ingin bertanya ide desain, warna, kemasan, atau target pasar.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral03),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F7A5900),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral02,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondary08),
            ),
            child: Center(
              child: AppIcon(
                AppIcons.brain(PhosphorIconsStyle.fill),
                color: AppColors.primary05,
                dimension: 24,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.neutral09,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.neutral08,
              height: 1.35,
            ),
          ),
          if (onCreateSession != null) ...[
            const SizedBox(height: 18),
            AppButton(
              label: isCreatingSession ? 'Membuat sesi...' : 'Mulai sesi chat',
              isLoading: isCreatingSession,
              onPressed: isCreatingSession ? null : onCreateSession,
              size: AppButtonSize.sm,
            ),
          ],
        ],
      ),
    );
  }
}

class _AiMessage extends StatelessWidget {
  const _AiMessage({required this.text, this.attachmentTitle, this.imageUrl});

  final String? attachmentTitle;
  final String? imageUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrainAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MessageBubble(
                text: text,
                color: AppColors.system01,
                borderColor: AppColors.neutral03,
              ),
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ChatAttachmentCard(
                  imageUrl: imageUrl!,
                  title: attachmentTitle ?? 'Referensi Desain',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.88,
        child: _MessageBubble(
          text: text,
          color: AppColors.neutral02,
          borderColor: AppColors.primary02,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.borderColor,
    required this.color,
    required this.text,
  });

  final Color borderColor;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F7A5900),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.neutral08,
          height: 1.45,
        ),
      ),
    );
  }
}

class _ChatAttachmentCard extends StatelessWidget {
  const _ChatAttachmentCard({required this.imageUrl, required this.title});

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral03),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F7A5900),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: isNetwork
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _AttachmentFallback(),
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _AttachmentFallback(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.neutral09,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppIcon(
                  AppIcons.download(),
                  color: AppColors.neutral08,
                  dimension: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Unduh',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentFallback extends StatelessWidget {
  const _AttachmentFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral03,
      alignment: Alignment.center,
      child: AppIcon(
        AppIcons.package(),
        color: AppColors.neutral07,
        dimension: 36,
      ),
    );
  }
}

class _BrainAvatar extends StatelessWidget {
  const _BrainAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.neutral02,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary08),
      ),
      child: Center(
        child: AppIcon(
          AppIcons.brain(PhosphorIconsStyle.fill),
          color: AppColors.primary05,
          dimension: 22,
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.system01,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A7A5900),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            AppIcon(
              AppIcons.addCircle(),
              color: AppColors.system07,
              dimension: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: onSend != null,
                decoration: InputDecoration(
                  hintText: onSend == null
                      ? 'Mulai sesi chat terlebih dahulu'
                      : 'Tanyakan ide desain...',
                  border: InputBorder.none,
                ),
              ),
            ),
            AppIcon(AppIcons.mic(), color: AppColors.system07, dimension: 22),
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isSending ? null : onSend,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary04,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: isSending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AppIcon(
                          AppIcons.send(),
                          color: AppColors.primary08,
                          dimension: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  const _ChatError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Coba lagi', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _BrainData {
  const _BrainData({
    required this.activeSession,
    required this.messages,
    required this.sessions,
  });

  final ChatSession? activeSession;
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
}

void _openProfile(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => const ProfilePage()));
}

void _openNotifications(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const NotificationPage()),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}

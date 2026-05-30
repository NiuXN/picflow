import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/sse_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  final _sse = SseService();
  final _scrollController = ScrollController();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
    _sse.onNotification = (json) {
      final newNotify = NotificationModel.fromJson(json);
      if (mounted) setState(() => _notifications.insert(0, newNotify));
    };
    _sse.connect();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sse.disconnect();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final items = await _service.getNotifications(page: 1);
    if (mounted) {
      setState(() {
        _notifications = items;
        _hasMore = items.length >= 20;
        _page = 1;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    final items = await _service.getNotifications(page: _page + 1);
    if (mounted) {
      setState(() {
        _notifications.addAll(items);
        _hasMore = items.length >= 20;
        _page++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('通知', style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.inversePrimary))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('暂无通知', style: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (_, i) {
                    final n = _notifications[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.inversePrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.campaign_outlined, color: AppColors.inversePrimary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                                if (n.content != null && n.content!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(n.content!, style: AppTypography.bodyRegular.copyWith(color: AppColors.onSurface, height: 1.5)),
                                ],
                                const SizedBox(height: 6),
                                Text(_formatTime(n.createdAt), style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

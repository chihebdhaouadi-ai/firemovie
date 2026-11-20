import 'package:cached_network_image/cached_network_image.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../data/messaging_models.dart';
import '../../../core/stable_image_key.dart';

/// The picture for a chat: the friend's avatar, a group icon, or a lock for
/// a private topic.
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.conversation,
    required this.meId,
    this.size = 46,
  });

  final Conversation conversation;
  final int? meId;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (conversation.isDirect) {
      final others = conversation.others(meId);
      final friend = others.isEmpty ? null : others.first;
      return AvatarFrame(
        size: size,
        avatarUrl: friend?.avatarUrl,
        initial: friend?.initial ?? '?',
        framed: false,
        animate: false,
        ringWidth: 0,
      );
    }
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: conversation.isTopic ? LuxeColors.text : LuxeColors.surface2,
        border: Border.all(color: LuxeColors.hair),
      ),
      child: Icon(
        conversation.isTopic
            ? BootstrapIcons.lock_fill
            : BootstrapIcons.people_fill,
        size: size * .45,
        color: conversation.isTopic ? LuxeColors.bg : LuxeColors.text,
      ),
    );
    final photo = conversation.photoUrl;
    if (photo == null || photo.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photo,
        cacheKey: stableImageKey(photo),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

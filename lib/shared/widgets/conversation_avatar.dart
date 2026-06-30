import 'package:flutter/material.dart';

import '../models/notification_models.dart';
import 'user_avatar.dart';

/// WhatsApp-style avatar: single face, pair, or collage for groups.
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.participants,
    this.type,
    this.title,
    this.size = 48,
  });

  final List<ConversationParticipantRef> participants;
  final String? type;
  final String? title;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (type == 'listing') {
      return _iconAvatar(context, Icons.storefront_outlined);
    }

    if (participants.isEmpty) {
      return UserAvatar(
        name: title,
        radius: size / 2,
      );
    }

    if (participants.length == 1) {
      final person = participants.first;
      return UserAvatar(
        name: person.name,
        avatarUrl: person.avatarUrl,
        radius: size / 2,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: _collage(context, participants.take(4).toList()),
      ),
    );
  }

  Widget _iconAvatar(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(icon, size: size * 0.45, color: theme.colorScheme.primary),
    );
  }

  Widget _collage(BuildContext context, List<ConversationParticipantRef> people) {
    if (people.length == 2) {
      return Row(
        children: [
          Expanded(child: _tile(context, people[0], alignment: Alignment.centerRight)),
          Expanded(child: _tile(context, people[1], alignment: Alignment.centerLeft)),
        ],
      );
    }

    if (people.length == 3) {
      return Column(
        children: [
          Expanded(
            child: _tile(context, people[0], alignment: Alignment.center),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _tile(context, people[1])),
                Expanded(child: _tile(context, people[2])),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _tile(context, people[0])),
              Expanded(child: _tile(context, people[1])),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _tile(context, people[2])),
              Expanded(
                child: people.length > 3
                    ? _tile(context, people[3])
                    : ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    ConversationParticipantRef person, {
    Alignment alignment = Alignment.center,
  }) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Align(
        alignment: alignment,
        child: UserAvatar(
          name: person.name,
          avatarUrl: person.avatarUrl,
          radius: size / 4.2,
        ),
      ),
    );
  }
}

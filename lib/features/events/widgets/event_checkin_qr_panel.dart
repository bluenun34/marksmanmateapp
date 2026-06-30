import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR + PIN display for event self check-in (matches website check-in desk).
class EventCheckinQrPanel extends StatelessWidget {
  const EventCheckinQrPanel({
    super.key,
    required this.checkinUrl,
    this.checkinPin,
    this.enabled = true,
  });

  final String? checkinUrl;
  final String? checkinPin;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pin = checkinPin?.trim();
    final url = checkinUrl?.trim();
    final dimmed = !enabled;

    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (url != null && url.isNotEmpty) ...[
            Text(
              'QR check-in',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Members scan this when self check-in is open. Requires login.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              url,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (pin != null && pin.isNotEmpty) ...[
            Text(
              'PIN check-in',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Read aloud for members entering the PIN manually.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                pin,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: dimmed
                    ? null
                    : () => Clipboard.setData(ClipboardData(text: pin)),
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy PIN'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

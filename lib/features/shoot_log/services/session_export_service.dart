import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/format/session_date_format.dart';
import '../../../shared/shoot_log/shoot_log_labels.dart';

class SessionExportService {
  static String buildText(ShootSession session) {
    final buffer = StringBuffer()
      ..writeln('MarksmanMate — Shoot session')
      ..writeln('${disciplineLabel(session.discipline)} · ${sessionTypeLabel(session.sessionType)}')
      ..writeln(formatSessionDateHuman(session.date))
      ..writeln('');

    if (session.rangeName?.isNotEmpty == true) {
      buffer.writeln('Range: ${session.rangeName}');
    }
    if (session.location?.isNotEmpty == true) {
      buffer.writeln('Location: ${session.location}');
    }
    if (session.totalRounds != null) {
      buffer.writeln('Rounds: ${session.totalRounds}');
    }
    if (session.totalHits != null || session.totalMisses != null) {
      buffer.writeln(
        'Hits: ${session.totalHits ?? '—'} · Misses: ${session.totalMisses ?? '—'}',
      );
    }
    if (session.totalScore != null) {
      buffer.writeln('Score: ${session.totalScore}');
    }
    if (session.rating != null && session.rating! > 0) {
      buffer.writeln('Rating: ${session.rating}/5');
    }
    if (session.weatherCondition?.isNotEmpty == true) {
      buffer.writeln('Weather: ${session.weatherCondition}');
    }
    if (session.notes?.isNotEmpty == true) {
      buffer
        ..writeln('')
        ..writeln('Notes:')
        ..writeln(session.notes);
    }

    buffer
      ..writeln('')
      ..writeln('Logged with MarksmanMate');
    return buffer.toString();
  }

  static Future<void> share(ShootSession session) async {
    await SharePlus.instance.share(
      ShareParams(text: buildText(session), subject: 'Shoot session'),
    );
  }
}

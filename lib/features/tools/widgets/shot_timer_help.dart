/// Copy for shot timer UI and guided setup.
abstract class ShotTimerHelp {
  static const introTitle = 'What is the shot timer?';

  static const introBody =
      'A par-time drill timer for the range. After a random wait, a loud beep tells '
      'you to start shooting. The clock runs until par time — how long you have to '
      'complete your string. Each shot is logged as a split so you can see pace and '
      'transitions.\n\n'
      'Use it for draw-and-shoot drills, plate runs, or any exercise where you want '
      'pressure from a countdown and a record of when each shot broke.\n\n'
      'Switch to Course run for full stages: no par cap — an assistant taps Finish '
      'when the shooter is done. Optionally set a max time (e.g. 120 s) for IPSC-style '
      'DNF limits.';

  static const runStyleTitle = 'Run style';
  static const runStyleBody =
      'Par drill stops automatically at par time — best for short strings and dry-fire '
      'pressure. Course run keeps counting until someone taps Finish — best when a '
      'range officer or buddy follows the shooter through a stage.';

  static const parDrillLabel = 'Par drill';
  static const courseRunLabel = 'Course run';

  static const courseLimitTitle = 'Course time limit';
  static const courseLimitBody =
      'Optional max time for a stage. When the limit is reached the run ends with a '
      'beep (DNF). Turn on Unlimited for no cap — the assistant stops the timer when '
      'the shooter finishes. IPSC production often uses around 2 minutes per stage.';

  static const parTitle = 'Par time';
  static const parBody =
      'How many seconds you have to finish the drill after the start beep. '
      'When the clock hits par, you hear a triple tone and the run ends. '
      'Example: par 3 s means your string should be done within three seconds of the beep.';

  static const delayTitle = 'Random start delay';
  static const delayBody =
      'How long you wait in the ready position before the start beep. '
      'A random delay between min and max stops you anticipating the signal — '
      'like a match start or defensive draw where you cannot predict the go.';

  static const delayMinTitle = 'Minimum delay';
  static const delayMinBody =
      'Shortest random wait before the beep. Set to 0 for instant starts after you tap Start.';

  static const delayMaxTitle = 'Maximum delay';
  static const delayMaxBody =
      'Longest random wait. The app picks any time between min and max each run. '
      'Wider range = less predictable start.';

  static const strictnessTitle = 'Mic strictness';
  static const strictnessBody =
      'How picky the microphone is about counting a shot. Gunshots are very short and '
      'sharp; talking and range noise are slower and smoother.\n\n'
      'Slide right if voices or other shooters cause false counts. Slide left only on a '
      'quiet bay when claps are not being detected.\n\n'
      'During setup the bar shows shot-likeness (impulse shape), not raw loudness — '
      'talking should keep it low; a hard clap should spike it.';
}

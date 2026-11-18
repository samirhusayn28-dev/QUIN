import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neo_palette.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_dialog.dart';

/// The developer's identity.
const String kDeveloperName = 'Samir Husayn';
const String kDeveloperGitHubUser = 'samirhusayn28-dev';
const String kDeveloperGitHubUrl = 'https://github.com/samirhusayn28-dev';
const String kDeveloperEmail = 'sameerhussainsoomro22@gmail.com';

/// The roles typed out under the name, one at a time, on a loop.
const List<String> kDeveloperRoles = <String>[
  'Web Developer',
  'Mobile Application Developer',
  'Software Developer',
  'Linux Power User',
];

/// The card's aspect ratio: the same 1.586 : 1 as a bank/ATM card. The height
/// is always derived from the width so the card never grows when text changes.
const double kDeveloperCardAspect = 1.586;

/// The widest the card is ever drawn (the host adds its own outer margin).
const double kDeveloperCardMaxWidth = 340;

/// The one "Designed & Developed By" card, shared by the Settings list and the
/// popup opened from the developer icon in the home top bar.
///
/// Fixed size: [kDeveloperCardMaxWidth] wide at most and [kDeveloperCardAspect]
/// tall. Content that cannot fit (larger text scales, narrow screens) is scaled
/// down rather than allowed to resize or overflow the card.
class DeveloperCard extends StatelessWidget {
  const DeveloperCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : kDeveloperCardMaxWidth;
        final width = available < kDeveloperCardMaxWidth
            ? available
            : kDeveloperCardMaxWidth;
        final height = width / kDeveloperCardAspect;

        return SizedBox(
          width: width,
          height: height,
          child: NeoCard(
            color: NeoPalette.paperAlt,
            padding: const EdgeInsets.all(16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width - 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Designed & Developed By',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFamily,
                        fontSize: 12,
                        color: NeoPalette.inkSoft,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      kDeveloperName,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFamily,
                        fontSize: 30,
                        height: 1.0,
                        letterSpacing: -0.6,
                        color: NeoPalette.ink,
                      ),
                    ),
                    SizedBox(height: 6),
                    _TypewriterRoles(),
                    SizedBox(height: 14),
                    _GitHubChip(),
                    SizedBox(height: 10),
                    _EmailRow(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The role line: types a role out, holds it, deletes it and moves to the next,
/// forever. One [AnimationController] drives everything (typing, the hold, the
/// deletion and the cursor blink); it is muted by Flutter whenever the card is
/// not visible (TickerMode) and disposed with the card.
class _TypewriterRoles extends StatefulWidget {
  const _TypewriterRoles();

  @override
  State<_TypewriterRoles> createState() => _TypewriterRolesState();
}

class _TypewriterRolesState extends State<_TypewriterRoles>
    with SingleTickerProviderStateMixin {
  static const int _typeMs = 60; // per character, typing
  static const int _deleteMs = 35; // per character, deleting
  static const int _holdMs = 1200; // full word, held
  static const int _gapMs = 350; // blank beat before the next role
  static const int _blinkMs = 800;

  late final AnimationController _controller =
      AnimationController(vsync: this)..addStatusListener(_onStatus);

  int _index = 0;
  int _totalMs = 1;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _index = (_index + 1) % kDeveloperRoles.length);
    _restart();
  }

  void _restart() {
    final length = kDeveloperRoles[_index].length;
    _totalMs = length * 60 + 1200 + length * 35 + 350;
    _controller.duration = Duration(milliseconds: _totalMs);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = kDeveloperRoles[_index];
    final typeEnd = role.length * 60;
    final holdEnd = typeEnd + 1200;
    final deleteEnd = holdEnd + role.length * 35;

    // A fixed height: the line never makes the card resize while typing.
    return SizedBox(
      height: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final elapsed = (_controller.value * _totalMs).round();
          final String shown;
          if (elapsed < typeEnd) {
            shown = role.substring(0, elapsed ~/ 60);
          } else if (elapsed < holdEnd) {
            shown = role;
          } else if (elapsed < deleteEnd) {
            final gone = (elapsed - holdEnd) ~/ 35;
            shown = role.substring(0, (role.length - gone).clamp(0, role.length));
          } else {
            shown = '';
          }
          final cursorOn = elapsed >= deleteEnd || (elapsed % 800) < 480;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                shown,
                style: AppTypography.grotesk(
                  size: 13,
                  weight: FontWeight.w700,
                  color: NeoPalette.inkSoft,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 2,
                height: 14,
                color: cursorOn ? NeoPalette.ink : Colors.transparent,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The GitHub username chip: the handle plus an icon button that opens the
/// profile in the platform browser.
class _GitHubChip extends StatelessWidget {
  const _GitHubChip();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: kDeveloperGitHubUrl,
      child: Material(
        color: NeoPalette.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: NeoPalette.ink, width: 3),
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
        ),
        child: InkWell(
          key: const Key('developer-github-button'),
          onTap: () => openDeveloperGitHub(context),
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(Icons.code_rounded, size: 16, color: NeoPalette.ink),
                SizedBox(width: 6),
                Text(
                  kDeveloperGitHubUser,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NeoPalette.ink,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.open_in_new, size: 13, color: NeoPalette.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The email row: tap the mail button (or the address) to open a mail composer.
class _EmailRow extends StatelessWidget {
  const _EmailRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: NeoPalette.ink,
          shape: const CircleBorder(),
          child: InkWell(
            key: const Key('developer-email-button'),
            customBorder: const CircleBorder(),
            onTap: () => openDeveloperEmail(context),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.mail_outline,
                size: 16,
                color: NeoPalette.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          kDeveloperEmail,
          style: AppTypography.grotesk(size: 12.5, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Kept for call sites that predate the card redesign: a chunky GitHub button.
class GitHubButton extends StatelessWidget {
  const GitHubButton({super.key, required this.onPressed, this.expand = false});

  final VoidCallback onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: NeoPalette.ink,
          border: Border.all(color: NeoPalette.ink, width: 3),
          borderRadius: BorderRadius.circular(NeoPalette.radiusSmall),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: NeoPalette.yellow,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.code_rounded, color: NeoPalette.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'GitHub',
              style: AppTypography.grotesk(
                size: 15,
                weight: FontWeight.w700,
                color: NeoPalette.white,
              ),
            ),
          ],
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Opens the developer's GitHub profile in the platform browser (never inside
/// the app). Failures are surfaced instead of throwing.
Future<void> openDeveloperGitHub(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final ok = await launchUrl(
      Uri.parse(kDeveloperGitHubUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && messenger != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open GitHub')),
      );
    }
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Could not open GitHub')),
    );
  }
}

/// Opens the developer's email address in the platform mail app (via `mailto`,
/// declared in the Android manifest `<queries>`). Failures are surfaced.
Future<void> openDeveloperEmail(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final ok = await launchUrl(
      Uri(scheme: 'mailto', path: kDeveloperEmail),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && messenger != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open email')),
      );
    }
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Could not open email')),
    );
  }
}

/// The animated popup version of the developer card, opened from the home top
/// bar: a small, centred, card-shaped panel with a dim barrier and a close X
/// overlapping its top-right corner. Closes on an outside tap, on system back,
/// or on the X.
Future<void> showDeveloperDialog(BuildContext context) {
  return showNeoDialog<void>(
    context: context,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            const DeveloperCard(),
            Positioned(
              top: -14,
              right: -14,
              child: Material(
                color: NeoPalette.ink,
                shape: const CircleBorder(),
                child: IconButton(
                  key: const Key('developer-dialog-close'),
                  iconSize: 18,
                  icon: const Icon(Icons.close, color: NeoPalette.white),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

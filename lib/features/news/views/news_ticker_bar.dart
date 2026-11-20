import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// One headline shown in the ticker: the movie card thumbnail + the news text.
@immutable
class NewsTickerItem {
  const NewsTickerItem({
    required this.id,
    required this.headline,
    required this.posterUrl,
  });

  final String id;
  final String headline;
  final String posterUrl;
}

/// "FILMSAGE NEWS | [poster] headline  [poster] headline ... >"
///
/// Headlines scroll continuously to the left, one after another, forever.
/// Pass already-localized strings; this widget only paints.
class NewsTickerBar extends StatelessWidget {
  const NewsTickerBar({
    required this.items,
    required this.onItemTap,
    required this.onSeeAllTap,
    this.pixelsPerSecond = 40,
    super.key,
  });

  final List<NewsTickerItem> items;
  final ValueChanged<String> onItemTap; // receives the item id
  final VoidCallback onSeeAllTap;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: scheme.surfaceContainerHighest.withValues(alpha: 3.35),
      ),
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      child: Row(
        children: [
          const _NewsBrand(),
          const SizedBox(width: 12),
          SizedBox(
            height: 28,
            child: VerticalDivider(
              width: 1,
              color: scheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRect(
              child: _TickerScroller(
                items: items,
                onItemTap: onItemTap,
                pixelsPerSecond: pixelsPerSecond,
              ),
            ),
          ),
          IconButton(
            tooltip: 'All news',
            onPressed: onSeeAllTap,
            icon: const Icon(BootstrapIcons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _NewsBrand extends StatelessWidget {
  const _NewsBrand();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FILMSAGE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: scheme.onSurface,
            height: 1.1,
          ),
        ),
        Text(
          'NEWS',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: scheme.primary,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// Auto-scrolls an infinite, looping list to the left using a Ticker.
class _TickerScroller extends StatefulWidget {
  const _TickerScroller({
    required this.items,
    required this.onItemTap,
    required this.pixelsPerSecond,
  });

  final List<NewsTickerItem> items;
  final ValueChanged<String> onItemTap;
  final double pixelsPerSecond;

  @override
  State<_TickerScroller> createState() => _TickerScrollerState();
}

class _TickerScrollerState extends State<_TickerScroller>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _paused = false;
  bool _reduceMotion = false;
  bool _pointerDown = false;
  bool _pointerInside = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_paused || !_controller.hasClients) return;
    _controller.jumpTo(
      _controller.offset + widget.pixelsPerSecond * dt,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "reduce motion": the headlines stay readable but don't move.
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _updatePaused();
  }

  void _updatePaused() {
    _paused = _reduceMotion || _pointerDown || _pointerInside;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    return Listener(
      // Hold the ticker while a pointer is over it or a finger is down so
      // desktop hover targets and taps remain stable.
      onPointerDown: (_) {
        _pointerDown = true;
        _updatePaused();
      },
      onPointerUp: (_) {
        _pointerDown = false;
        _updatePaused();
      },
      onPointerCancel: (_) {
        _pointerDown = false;
        _updatePaused();
      },
      child: MouseRegion(
        onEnter: (_) {
          _pointerInside = true;
          _updatePaused();
        },
        onExit: (_) {
          _pointerInside = false;
          _updatePaused();
        },
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          // No itemCount => infinite; modulo makes it loop news after news.
          itemBuilder: (context, index) {
            final item = items[index % items.length];
            return _TickerEntry(
              item: item,
              onTap: () => widget.onItemTap(item.id),
            );
          },
        ),
      ),
    );
  }
}

class _TickerEntry extends StatelessWidget {
  const _TickerEntry({required this.item, required this.onTap});

  final NewsTickerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 40),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.posterUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: 40,
                  height: 40,
                  child: ColoredBox(color: scheme.surfaceContainerHighest),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item.headline,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

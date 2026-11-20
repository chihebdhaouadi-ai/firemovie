import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';

/// An emoji with the words it is found by and its category.
typedef EmojiEntry = ({String emoji, String words, EmojiCategory category});

enum EmojiCategory { frequent, faces, hands, objects, symbols }

const List<EmojiEntry> chatEmojis = [
  (emoji: '🇹🇳', words: 'tunisia flag', category: EmojiCategory.frequent),
  (emoji: '🥲', words: 'smile tear', category: EmojiCategory.frequent),
  (emoji: '🍿', words: 'popcorn', category: EmojiCategory.frequent),
  (emoji: '🚀', words: 'rocket', category: EmojiCategory.frequent),
  (emoji: '🎥', words: 'movie camera film', category: EmojiCategory.frequent),
  (emoji: '🤟', words: 'love you hand', category: EmojiCategory.frequent),
  (emoji: '🎯', words: 'target', category: EmojiCategory.frequent),
  (emoji: '👽', words: 'alien', category: EmojiCategory.frequent),
  (emoji: '😂', words: 'laugh joy', category: EmojiCategory.faces),
  (emoji: '😍', words: 'love eyes', category: EmojiCategory.faces),
  (emoji: '😎', words: 'cool', category: EmojiCategory.faces),
  (emoji: '🤔', words: 'think', category: EmojiCategory.faces),
  (emoji: '😭', words: 'cry', category: EmojiCategory.faces),
  (emoji: '🥹', words: 'touched', category: EmojiCategory.faces),
  (emoji: '😮', words: 'wow', category: EmojiCategory.faces),
  (emoji: '🙃', words: 'upside down', category: EmojiCategory.faces),
  (emoji: '😢', words: 'sad', category: EmojiCategory.faces),
  (emoji: '🤯', words: 'mind blown', category: EmojiCategory.faces),
  (emoji: '👍', words: 'thumbs up', category: EmojiCategory.hands),
  (emoji: '👎', words: 'thumbs down', category: EmojiCategory.hands),
  (emoji: '👏', words: 'clap', category: EmojiCategory.hands),
  (emoji: '🙏', words: 'pray thanks', category: EmojiCategory.hands),
  (emoji: '💪', words: 'muscle', category: EmojiCategory.hands),
  (emoji: '🤝', words: 'handshake', category: EmojiCategory.hands),
  (emoji: '🎬', words: 'clapper film', category: EmojiCategory.objects),
  (emoji: '🏆', words: 'trophy', category: EmojiCategory.objects),
  (emoji: '🎉', words: 'party', category: EmojiCategory.objects),
  (emoji: '☕', words: 'coffee', category: EmojiCategory.objects),
  (emoji: '🍕', words: 'pizza', category: EmojiCategory.objects),
  (emoji: '📅', words: 'calendar', category: EmojiCategory.objects),
  (emoji: '🔥', words: 'fire', category: EmojiCategory.symbols),
  (emoji: '❤️', words: 'heart', category: EmojiCategory.symbols),
  (emoji: '💯', words: 'hundred', category: EmojiCategory.symbols),
  (emoji: '✅', words: 'check', category: EmojiCategory.symbols),
  (emoji: '❌', words: 'cross', category: EmojiCategory.symbols),
  (emoji: '⭐', words: 'star', category: EmojiCategory.symbols),
];

/// A GIF: its name, the emoji drawn on it and its two colours. The GIFs are
/// animated tiles made in the app, not files.
typedef ChatGif = ({String name, String emoji, Color from, Color to});

const List<ChatGif> chatGifs = [
  (
    name: 'applause',
    emoji: '👏',
    from: Color(0xFFC0392B),
    to: Color(0xFFF39C12)
  ),
  (
    name: 'mind blown',
    emoji: '🤯',
    from: Color(0xFF6C3483),
    to: Color(0xFF2980B9)
  ),
  (
    name: 'popcorn',
    emoji: '🍿',
    from: Color(0xFFD68910),
    to: Color(0xFF7B241C)
  ),
  (
    name: 'laughing',
    emoji: '😂',
    from: Color(0xFF117A65),
    to: Color(0xFFF1C40F)
  ),
  (
    name: 'deal with it',
    emoji: '😎',
    from: Color(0xFF1F618D),
    to: Color(0xFF1C2833)
  ),
  (name: 'wow', emoji: '😮', from: Color(0xFFA93226), to: Color(0xFF8E44AD)),
  (
    name: 'on fire',
    emoji: '🔥',
    from: Color(0xFFE67E22),
    to: Color(0xFF922B21)
  ),
  (
    name: 'facepalm',
    emoji: '🤦',
    from: Color(0xFF5D6D7E),
    to: Color(0xFF2C3E50)
  ),
  (
    name: 'thank you',
    emoji: '🙏',
    from: Color(0xFF1E8449),
    to: Color(0xFF148F77)
  ),
  (name: 'party', emoji: '🎉', from: Color(0xFFC2185B), to: Color(0xFF7B1FA2)),
];

ChatGif? gifNamed(String? name) {
  for (final gif in chatGifs) {
    if (gif.name == name) return gif;
  }
  return null;
}

/// The five quick reactions, and the ten a post may allow.
const defaultReactions = ['👍', '❤️', '😂', '🔥', '😮'];
const reactionPool = [
  '👍',
  '❤️',
  '🔥',
  '😂',
  '😮',
  '😢',
  '🎉',
  '👏',
  '🤯',
  '💯'
];

enum EmojiPanelTab { emoji, gif, sticker }

/// What was picked in the panel.
sealed class PanelPick {
  const PanelPick();
}

final class PickedEmoji extends PanelPick {
  const PickedEmoji(this.emoji);
  final String emoji;
}

final class PickedGif extends PanelPick {
  const PickedGif(this.name);
  final String name;
}

final class PickedSticker extends PanelPick {
  const PickedSticker(this.emoji);
  final String emoji;
}

/// The bottom panel with Emoji, GIF and Stickers tabs, a search field and,
/// for emoji, a bar to jump between categories. [emojiOnly] (when picking a
/// reaction) hides the tabs.
class EmojiPanel extends StatefulWidget {
  const EmojiPanel({
    super.key,
    required this.onPick,
    required this.onClose,
    this.emojiOnly = false,
  });

  final ValueChanged<PanelPick> onPick;
  final VoidCallback onClose;
  final bool emojiOnly;

  @override
  State<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<EmojiPanel> {
  EmojiPanelTab _tab = EmojiPanelTab.emoji;
  String _query = '';
  final _list = ScrollController();
  final _sections = {for (final c in EmojiCategory.values) c: GlobalKey()};

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, EmojiCategory c) => switch (c) {
        EmojiCategory.frequent => l10n.chatCatFrequent,
        EmojiCategory.faces => l10n.chatCatFaces,
        EmojiCategory.hands => l10n.chatCatHands,
        EmojiCategory.objects => l10n.chatCatObjects,
        EmojiCategory.symbols => l10n.chatCatSymbols,
      };

  static const _categoryIcon = {
    EmojiCategory.frequent: '🕘',
    EmojiCategory.faces: '🙂',
    EmojiCategory.hands: '👋',
    EmojiCategory.objects: '🍿',
    EmojiCategory.symbols: '❤️',
  };

  void _jump(EmojiCategory c) {
    final target = _sections[c]?.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(target,
          duration: const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hint = switch (_tab) {
      EmojiPanelTab.emoji => l10n.chatSearchEmoji,
      EmojiPanelTab.gif => l10n.chatSearchGif,
      EmojiPanelTab.sticker => l10n.chatSearchStickers,
    };
    return Container(
      key: const Key('emoji-panel'),
      height: 300,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: LuxeColors.bg,
        border: Border(top: BorderSide(color: LuxeColors.hair)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: l10n.chatClosePicker,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: LuxeColors.hair,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          if (!widget.emojiOnly) ...[
            _Tabs(
              tab: _tab,
              onTab: (tab) => setState(() {
                _tab = tab;
                _query = '';
              }),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: 40,
            child: TextField(
              key: const Key('emoji-search'),
              onChanged: (value) => setState(() => _query = value),
              style: TextStyle(color: LuxeColors.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: LuxeColors.muted, fontSize: 14),
                prefixIcon: Icon(BootstrapIcons.search,
                    size: 15, color: LuxeColors.muted),
                isDense: true,
                filled: true,
                fillColor: LuxeColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: LuxeColors.hair),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: LuxeColors.hair),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: _content(l10n)),
          if (_tab == EmojiPanelTab.emoji && _query.isEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: LuxeColors.hair)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final c in EmojiCategory.values)
                    IconButton(
                      tooltip: _label(l10n, c),
                      onPressed: () => _jump(c),
                      icon: Text(_categoryIcon[c]!,
                          style: const TextStyle(fontSize: 18)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(AppLocalizations l10n) {
    final q = _query.trim().toLowerCase();
    final nothing = Center(
      child: Text(
        l10n.chatNothingFound(_query),
        style: TextStyle(color: LuxeColors.muted),
      ),
    );
    if (_tab == EmojiPanelTab.gif) {
      final gifs = chatGifs.where((g) => g.name.contains(q)).toList();
      if (gifs.isEmpty) return nothing;
      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.9,
        children: [
          for (final gif in gifs)
            GifTile(
              key: Key('gif-${gif.name}'),
              gif: gif,
              onTap: () => widget.onPick(PickedGif(gif.name)),
            ),
        ],
      );
    }
    final sticker = _tab == EmojiPanelTab.sticker;
    Widget cell(EmojiEntry e) => InkWell(
          key: Key('${sticker ? 'sticker' : 'emoji'}-${e.emoji}'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => widget
              .onPick(sticker ? PickedSticker(e.emoji) : PickedEmoji(e.emoji)),
          child: Center(
            child: Text(e.emoji, style: TextStyle(fontSize: sticker ? 46 : 26)),
          ),
        );
    Widget grid(List<EmojiEntry> list) => GridView.count(
          crossAxisCount: sticker ? 3 : 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [for (final e in list) cell(e)],
        );
    if (q.isNotEmpty || sticker) {
      final list = chatEmojis.where((e) => e.words.contains(q)).toList();
      if (list.isEmpty) return nothing;
      return SingleChildScrollView(child: grid(list));
    }
    return SingleChildScrollView(
      controller: _list,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in EmojiCategory.values) ...[
            Padding(
              key: _sections[c],
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 6),
              child: Text(
                _label(l10n, c),
                style: TextStyle(color: LuxeColors.muted, fontSize: 13),
              ),
            ),
            grid(chatEmojis.where((e) => e.category == c).toList()),
          ],
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onTab});

  final EmojiPanelTab tab;
  final ValueChanged<EmojiPanelTab> onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      EmojiPanelTab.emoji: l10n.chatTabEmoji,
      EmojiPanelTab.gif: l10n.chatTabGif,
      EmojiPanelTab.sticker: l10n.chatTabStickers,
    };
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final entry in labels.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: entry.key == tab,
                child: GestureDetector(
                  key: Key('panel-tab-${entry.key.name}'),
                  onTap: () => onTab(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: entry.key == tab
                          ? LuxeColors.text
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color:
                            entry.key == tab ? LuxeColors.bg : LuxeColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A GIF: a gradient tile with its emoji bobbing gently and its name.
class GifTile extends StatefulWidget {
  const GifTile({super.key, required this.gif, this.onTap, this.big = false});

  final ChatGif gif;
  final VoidCallback? onTap;
  final bool big;

  @override
  State<GifTile> createState() => _GifTileState();
}

class _GifTileState extends State<GifTile> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _bob.stop();
    } else if (!_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gif = widget.gif;
    final tile = Container(
      width: widget.big ? 200 : null,
      height: widget.big ? 130 : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gif.from, gif.to],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _bob,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -6 * _bob.value),
                child: child,
              ),
              child: Text(gif.emoji,
                  style: TextStyle(fontSize: widget.big ? 54 : 34)),
            ),
          ),
          PositionedDirectional(
            start: 8,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'GIF ${gif.name}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
    final onTap = widget.onTap;
    if (onTap == null) return tile;
    return GestureDetector(onTap: onTap, child: tile);
  }
}

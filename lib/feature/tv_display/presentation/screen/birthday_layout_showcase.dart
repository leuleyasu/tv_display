import 'package:flutter/material.dart';
import '../widget/birthday_overlay/birthday_overlay.dart';

class BirthdayLayoutShowcase extends StatefulWidget {
  const BirthdayLayoutShowcase({super.key});

  @override
  State<BirthdayLayoutShowcase> createState() => _BirthdayLayoutShowcaseState();
}

class _BirthdayLayoutShowcaseState extends State<BirthdayLayoutShowcase> {
  final PageController _pageCtrl = PageController();
  int _index = 0;

  final TextEditingController _nameCtrl = TextEditingController(text: 'SARAH');
  final TextEditingController _wishCtrl =
      TextEditingController(text: 'Hope your day is as amazing as you are! 🎉');

  Color _accent = const Color(0xFFFBBF24);
  String? _imageUrl = 'assets/images/lid.jpg';
  bool _isAsset = true;
  bool _showAll = false;

  static const _newLayouts = [
    BirthdayLayout.stories,
    BirthdayLayout.confettiPop,
    BirthdayLayout.magazine,
    BirthdayLayout.photoBooth,
    BirthdayLayout.balloons,
    BirthdayLayout.retroGeometric,
  ];

  static const _allLayouts = [
    BirthdayLayout.post,
    BirthdayLayout.polaroid,
    BirthdayLayout.split,
    BirthdayLayout.neon,
    BirthdayLayout.glass,
    BirthdayLayout.cinema,
    BirthdayLayout.bento,
    BirthdayLayout.aurora,
    BirthdayLayout.hud,
    BirthdayLayout.terminal,
    BirthdayLayout.aiChat,
    BirthdayLayout.hologram,
    BirthdayLayout.stories,
    BirthdayLayout.confettiPop,
    BirthdayLayout.magazine,
    BirthdayLayout.photoBooth,
    BirthdayLayout.balloons,
    BirthdayLayout.retroGeometric,
  ];

  static const _accentOptions = [
    Color(0xFFFBBF24),
    Color(0xFFFF007A),
    Color(0xFF7A00FF),
    Color(0xFF22D3EE),
    Color(0xFF06FFA5),
    Color(0xFFFF6B35),
  ];

  List<BirthdayLayout> get _layouts => _showAll ? _allLayouts : _newLayouts;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _wishCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _layouts.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prev() {
    if (_index > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _jumpTo(int i) {
    _pageCtrl.jumpToPage(i);
  }

  void _randomize() {
    final names = ['SARAH', 'JAMIE', 'NOAH', 'ARIA', 'KAI', 'MIRA', 'LEO'];
    final wishes = [
      "Hope your day is as amazing as you are! 🎉",
      'Another year of magic ✨',
      'Make a wish 🌟',
      'Shine bright today 🎉',
      'All night long 🥂',
    ];
    final now = DateTime.now();
    setState(() {
      _nameCtrl.text = names[now.millisecondsSinceEpoch % names.length];
      _wishCtrl.text = wishes[now.microsecondsSinceEpoch % wishes.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final layoutName = _layouts[_index].toString().split('.').last;

    return Scaffold(
      backgroundColor: const Color(0xFF070712),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(layoutName),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _layouts.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (ctx, i) {
                  return BirthdayOverlay(
                    layout: _layouts[i],
                    imageUrl: _imageUrl,
                    isAsset: _isAsset,
                    name: _nameCtrl.text.isEmpty ? 'FRIEND' : _nameCtrl.text,
                    wish: _wishCtrl.text,
                    scale: 1.0,
                    accentColor: _accent,
                  );
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String layoutName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(layoutName.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5)),
                const SizedBox(height: 2),
                Text(
                    '${_index + 1} of ${_layouts.length}'
                    '${_showAll ? ' · all layouts' : ' · new only'}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _showAll = !_showAll;
              _index = 0;
              _jumpTo(0);
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _showAll
                    ? _accent.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color:
                      _showAll ? _accent : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(_showAll ? 'ALL' : 'NEW',
                  style: TextStyle(
                      color: _showAll ? _accent : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Preview fullscreen',
            icon: const Icon(Icons.open_in_full, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullscreenPreview(
                      layout: _layouts[_index],
                      imageUrl: _imageUrl,
                      isAsset: _isAsset,
                      name: _nameCtrl.text.isEmpty ? 'FRIEND' : _nameCtrl.text,
                      wish: _wishCtrl.text,
                      accent: _accent,
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _miniField(
                    controller: _nameCtrl,
                    hint: 'Name',
                    onChanged: (_) => setState(() {})),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _miniField(
                    controller: _wishCtrl,
                    hint: 'Wish message',
                    onChanged: (_) => setState(() {})),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Randomize',
                onPressed: _randomize,
                icon: const Icon(Icons.shuffle, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('ACCENT',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5)),
              const SizedBox(width: 12),
              ..._accentOptions.map((c) {
                final selected = c.value == _accent.value;
                return GestureDetector(
                  onTap: () => setState(() => _accent = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          width: selected ? 2.5 : 1),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: c.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1)
                            ]
                          : null,
                    ),
                  ),
                );
              }),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_layouts.length, (i) {
                  return GestureDetector(
                    onTap: () => _jumpTo(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: i == _index
                              ? _accent
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3)),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _index == 0 ? null : _prev,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Prev'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _index == _layouts.length - 1 ? null : _next,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Next layout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _accent.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accent, width: 1),
        ),
      ),
    );
  }
}

class _FullscreenPreview extends StatelessWidget {
  final BirthdayLayout layout;
  final String? imageUrl;
  final bool isAsset;
  final String name;
  final String wish;
  final Color accent;

  const _FullscreenPreview({
    required this.layout,
    required this.imageUrl,
    required this.isAsset,
    required this.name,
    required this.wish,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070712),
      body: Stack(
        children: [
          Positioned.fill(
            child: BirthdayOverlay(
              layout: layout,
              imageUrl: imageUrl,
              isAsset: isAsset,
              name: name,
              wish: wish,
              scale: 1.0,
              accentColor: accent,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

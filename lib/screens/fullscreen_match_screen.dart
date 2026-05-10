// lib/screens/fullscreen_match_screen.dart
import 'package:flutter/material.dart';
import '../models/ai_match_model.dart';
import '../models/character_model.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';
import '../services/share_service.dart';   // ← импорт сервиса шаринга

class FullscreenMatchScreen extends StatefulWidget {
  final AIMatch aiMatch;
  final Character character;
  final UserProfile userProfile;
  final String pathType;

  const FullscreenMatchScreen({
    super.key,
    required this.aiMatch,
    required this.character,
    required this.userProfile,
    required this.pathType,
  });

  @override
  State<FullscreenMatchScreen> createState() => _FullscreenMatchScreenState();
}

class _FullscreenMatchScreenState extends State<FullscreenMatchScreen> {
  bool _statsVisible = true;
  final ScrollController _scrollController = ScrollController();

  TextStyle get _titleStyle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black,
        blurRadius: 15,
        offset: Offset(2, 2),
      ),
    ],
  );

  TextStyle get _subtitleStyle => TextStyle(
    fontSize: 20,
    color: Colors.white.withOpacity(0.9),
    fontWeight: FontWeight.w500,
    shadows: [
      const Shadow(
        color: Colors.black,
        blurRadius: 10,
      ),
    ],
  );

  Widget _buildTextOverlay(Widget child, {double opacity = 0.3}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _buildAnimatedPercentage() {
    return TweenAnimationBuilder<int>(
      duration: const Duration(milliseconds: 2000),
      tween: IntTween(begin: 0, end: widget.aiMatch.compatibilityScore),
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: widget.aiMatch.matchColor,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 20,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'СОВМЕСТИМОСТЬ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompatibilityCircle() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.6),
        border: Border.all(
          color: widget.aiMatch.matchColor.withOpacity(0.9),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.aiMatch.matchColor.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          const BoxShadow(
            color: Colors.black,
            blurRadius: 20,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Center(
        child: _buildAnimatedPercentage(),
      ),
    );
  }

  Widget _buildDimensionIndicator(String label, int value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.aiMatch.matchColor.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            '$value%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.aiMatch.matchColor,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenPhoto() {
    return Hero(
      tag: 'character_${widget.character.id}',
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.character.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safePaddingTop = mediaQuery.padding.top;
    final safePaddingBottom = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildFullscreenPhoto(),
          AnimatedOpacity(
            opacity: _statsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                top: safePaddingTop + 12,
                bottom: safePaddingBottom + 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.6),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextOverlay(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.character.name,
                          style: _titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.character.profession,
                          style: _subtitleStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    opacity: 0.4,
                  ),
                  const SizedBox(height: 30),
                  _buildTextOverlay(
                    Text(
                      widget.aiMatch.matchDescription.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.aiMatch.matchColor,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    opacity: 0.5,
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.aiMatch.dimensionScores.entries
                        .map((entry) =>
                        _buildDimensionIndicator(entry.key, entry.value))
                        .toList(),
                  ),
                  const SizedBox(height: 30),
                  _buildTextOverlay(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔑 КЛЮЧЕВЫЕ ПРИЧИНЫ СОВМЕСТИМОСТИ:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.aiMatch.compatibilityReasons.map((reason) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    opacity: 0.5,
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      _buildCompatibilityCircle(),
                      const SizedBox(height: 20),
                      _buildTextOverlay(
                        Text(
                          'Ваш уровень совместимости\nс ${widget.character.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        opacity: 0.4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: widget.aiMatch.matchColor.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                            const BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  characterName: widget.character.name,
                                  userProfile: widget.userProfile,
                                  pathType: widget.pathType,
                                  characterImage: widget.character.imagePath,
                                  characterProfession: widget.character.profession,
                                  characterPersonality: widget.character.personality,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.aiMatch.matchColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          icon: const Icon(Icons.chat, size: 26),
                          label: const Text(
                            'Начать общение',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final bool isUserFemale = widget.userProfile.gender == 'Женский';
                            final String userVerb = isUserFemale ? 'нашла' : 'нашёл';

                            final String shareText =
                                "✨ Я $userVerb идеального партнёра в Soul Pair! ✨\n\n"
                                "${widget.aiMatch.compatibilityScore}% совместимости.\n"
                                "Присоединяйтесь к приложению и найдите свою пару!";
                            await ShareService.shareText(shareText);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.share, size: 24),
                          label: const Text(
                            'Поделиться',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: safePaddingBottom + 10),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: safePaddingBottom + 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.6),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _statsVisible = !_statsVisible;
                  });
                },
                icon: Icon(
                  _statsVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
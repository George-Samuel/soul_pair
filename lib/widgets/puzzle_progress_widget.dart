import 'package:flutter/material.dart';

class PuzzleProgressWidget extends StatelessWidget {
  final int currentStep; // Текущий шаг (0-12)
  final int totalSteps; // Всего шагов (13)
  final String imageAsset; // Путь к изображению
  final double imageHeightFactor; // Коэффициент высоты изображения

  const PuzzleProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.imageAsset,
    this.imageHeightFactor = 0.44, // По умолчанию 44% высоты экрана
  }) : assert(currentStep >= 0 && currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    // РАСЧЕТ РАЗМЕРОВ С УЧЕТОМ БЕЗОПАСНЫХ ОБЛАСТЕЙ
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final paddingTop = mediaQuery.padding.top;
    final paddingBottom = mediaQuery.padding.bottom;

    // Вычисляем доступную высоту для изображения
    final availableHeight = screenHeight - paddingTop - paddingBottom;

    // Размеры изображения
    final imageWidth = screenWidth * 0.96; // 96% ширины экрана
    final imageHeight = availableHeight * imageHeightFactor;

    // Проверяем, нужно ли показывать процент
    final showPercentage = progress < 0.98;

    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 4,
        left: screenWidth * 0.02,
        right: screenWidth * 0.02,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // БОЛЬШОЕ ИЗОБРАЖЕНИЕ ПАЗЛА
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.purple.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ФОН: Затемненное изображение
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.85 - (progress * 0.7)),
                    colorBlendMode: BlendMode.darken,
                  ),

                  // ПЕРЕДНИЙ ПЛАН: Постепенно проявляющееся изображение
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: progress,
                    curve: Curves.easeInOut,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // КОРРЕКТНЫЙ if-else БЛОК (исправлена ошибка)
                  if (showPercentage)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPiecesText(currentStep),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // АНИМАЦИЯ ЗАВЕРШЕНИЯ
                    Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // ТЕКУЩИЙ ШАГ В ВЕРХНЕМ ПРАВОМ УГЛУ (МИНИМАЛИСТИЧНЫЙ)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${currentStep + 1}/$totalSteps',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // ТОНКИЙ ПРОГРЕСС-БАР ВНИЗУ (ОПЦИОНАЛЬНО)
                  if (progress < 1.0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          color: _getProgressColor(progress),
                          borderRadius: BorderRadius.zero,
                          minHeight: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // МИНИМАЛЬНЫЙ ОТСТУП СНИЗУ
          SizedBox(height: screenHeight * 0.01),
        ],
      ),
    );
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.orangeAccent;
    if (progress < 0.7) return Colors.blueAccent;
    return Colors.greenAccent;
  }

  String _getPiecesText(int current) {
    final remaining = totalSteps - current - 1;
    if (remaining <= 0) return 'завершено';
    if (remaining == 1) return 'остался 1';
    return 'осталось $remaining';
  }
}

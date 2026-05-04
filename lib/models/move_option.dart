import 'promotion_choice.dart';
import 'square_position.dart';

class MoveOption {
  const MoveOption({
    required this.from,
    required this.to,
    this.isCapture = false,
    this.isPromotion = false,
    this.isKingSideCastle = false,
    this.isQueenSideCastle = false,
    this.isEnPassant = false,
    this.promotion,
  });

  final SquarePosition from;
  final SquarePosition to;
  final bool isCapture;
  final bool isPromotion;
  final bool isKingSideCastle;
  final bool isQueenSideCastle;
  final bool isEnPassant;
  final PromotionChoice? promotion;

  MoveOption copyWith({PromotionChoice? promotion}) {
    return MoveOption(
      from: from,
      to: to,
      isCapture: isCapture,
      isPromotion: isPromotion,
      isKingSideCastle: isKingSideCastle,
      isQueenSideCastle: isQueenSideCastle,
      isEnPassant: isEnPassant,
      promotion: promotion ?? this.promotion,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MoveOption &&
        other.from == from &&
        other.to == to &&
        other.isCapture == isCapture &&
        other.isPromotion == isPromotion &&
        other.isKingSideCastle == isKingSideCastle &&
        other.isQueenSideCastle == isQueenSideCastle &&
        other.isEnPassant == isEnPassant &&
        other.promotion == promotion;
  }

  @override
  int get hashCode => Object.hash(
    from,
    to,
    isCapture,
    isPromotion,
    isKingSideCastle,
    isQueenSideCastle,
    isEnPassant,
    promotion,
  );
}

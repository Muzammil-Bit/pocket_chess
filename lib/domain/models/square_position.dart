class SquarePosition {
  const SquarePosition({required this.file, required this.rank});

  final int file;
  final int rank;

  factory SquarePosition.fromAlgebraic(String value) {
    final file = value.codeUnitAt(0) - 97;
    final boardRank = int.parse(value[1]);
    return SquarePosition(file: file, rank: 8 - boardRank);
  }

  String get algebraic => '${String.fromCharCode(97 + file)}${8 - rank}';

  @override
  bool operator ==(Object other) {
    return other is SquarePosition && other.file == file && other.rank == rank;
  }

  @override
  int get hashCode => Object.hash(file, rank);
}

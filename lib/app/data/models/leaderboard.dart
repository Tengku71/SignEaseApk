class UserLeaderboard {
  final String nama;
  final int points;

  UserLeaderboard({required this.nama, required this.points});

  factory UserLeaderboard.fromJson(Map<String, dynamic> json) {
    return UserLeaderboard(
      nama: json['nama'] ?? 'Unknown',
      points: json['points'] is int
          ? json['points']
          : int.tryParse(json['points'].toString()) ?? 0,
    );
  }
}

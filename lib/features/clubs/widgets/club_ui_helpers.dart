String formatClubRole(String? role) {
  if (role == null || role.trim().isEmpty) return 'Member';
  return switch (role.trim().toLowerCase()) {
    'owner' => 'Owner',
    'admin' => 'Admin',
    'poster' => 'Poster',
    'member' => 'Member',
    'mod' => 'Moderator',
    _ => role,
  };
}

String formatClubStatus(String? status) {
  if (status == null || status.trim().isEmpty) return 'Active';
  return switch (status.trim().toLowerCase()) {
    'active' => 'Active',
    'pending' => 'Pending',
    'probation' => 'Probation',
    'banned' => 'Banned',
    'left' => 'Left',
    _ => status,
  };
}

bool clubStatusNeedsAttention(String? status) {
  return status == 'pending' || status == 'probation';
}

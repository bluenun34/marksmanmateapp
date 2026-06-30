String formatGroupRole(String? role) {
  if (role == null || role.trim().isEmpty) return 'Member';
  return switch (role.trim().toLowerCase()) {
    'owner' => 'Owner',
    'admin' => 'Admin',
    'member' => 'Member',
    _ => role,
  };
}

String formatGroupStatus(String? status) {
  if (status == null || status.trim().isEmpty) return 'Active';
  return switch (status.trim().toLowerCase()) {
    'active' => 'Active',
    'invited' => 'Invited',
    'banned' => 'Banned',
    'left' => 'Left',
    _ => status,
  };
}

bool groupStatusNeedsAttention(String? status) {
  return status == 'invited';
}

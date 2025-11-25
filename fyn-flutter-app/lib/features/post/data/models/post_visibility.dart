enum PostVisibility {
  public,
  followers,
  private;

  static PostVisibility fromServerValue(String? value) {
    switch (value) {
      case 'FOLLOWERS':
        return PostVisibility.followers;
      case 'PRIVATE':
        return PostVisibility.private;
      case 'PUBLIC':
      default:
        return PostVisibility.public;
    }
  }

  String get serverValue {
    switch (this) {
      case PostVisibility.followers:
        return 'FOLLOWERS';
      case PostVisibility.private:
        return 'PRIVATE';
      case PostVisibility.public:
      default:
        return 'PUBLIC';
    }
  }
}


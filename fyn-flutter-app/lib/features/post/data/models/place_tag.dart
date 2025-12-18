/// Place tags matching backend PlaceTag enum
enum PlaceTag {
  hanoi('HANOI', 'Hà Nội'),
  hoChiMinh('HCMC', 'TP. Hồ Chí Minh'),
  daNang('DA_NANG', 'Đà Nẵng'),
  haiPhong('HAI_PHONG', 'Hải Phòng'),
  canTho('CAN_THO', 'Cần Thơ'),
  nhaTrang('NHA_TRANG', 'Nha Trang'),
  hue('HUE', 'Huế'),
  vungTau('VUNG_TAU', 'Vũng Tàu'),
  daLat('DA_LAT', 'Đà Lạt'),
  quyNhon('QUY_NHON', 'Quy Nhơn');

  final String code;
  final String displayName;

  const PlaceTag(this.code, this.displayName);

  /// Find PlaceTag by code
  static PlaceTag? fromCode(String code) {
    try {
      return PlaceTag.values.firstWhere((tag) => tag.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get all place tags as list
  static List<PlaceTag> get allPlaces => PlaceTag.values;
}

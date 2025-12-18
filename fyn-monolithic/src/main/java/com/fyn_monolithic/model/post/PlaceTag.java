package com.fyn_monolithic.model.post;

import lombok.Getter;

/**
 * Predefined places that users can tag in their posts.
 * Each place has a code (for storage/API) and a display name.
 */
@Getter
public enum PlaceTag {
    HANOI("HANOI", "Hà Nội"),
    HO_CHI_MINH("HCMC", "TP. Hồ Chí Minh"),
    DA_NANG("DA_NANG", "Đà Nẵng"),
    HAI_PHONG("HAI_PHONG", "Hải Phòng"),
    CAN_THO("CAN_THO", "Cần Thơ"),
    NHA_TRANG("NHA_TRANG", "Nha Trang"),
    HUE("HUE", "Huế"),
    VUNG_TAU("VUNG_TAU", "Vũng Tàu"),
    DA_LAT("DA_LAT", "Đà Lạt"),
    QUY_NHON("QUY_NHON", "Quy Nhơn");

    private final String code;
    private final String displayName;

    PlaceTag(String code, String displayName) {
        this.code = code;
        this.displayName = displayName;
    }

    /**
     * Find PlaceTag by code (case-insensitive)
     */
    public static PlaceTag fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (PlaceTag tag : values()) {
            if (tag.code.equalsIgnoreCase(code)) {
                return tag;
            }
        }
        return null;
    }

    /**
     * Validate if a code exists
     */
    public static boolean isValidCode(String code) {
        return fromCode(code) != null;
    }
}

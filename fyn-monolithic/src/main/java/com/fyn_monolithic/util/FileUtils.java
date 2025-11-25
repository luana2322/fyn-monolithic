package com.fyn_monolithic.util;

import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public final class FileUtils {

    private FileUtils() {
    }

    public static byte[] toBytes(MultipartFile file) {
        try {
            return file.getBytes();
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to read uploaded file", ex);
        }
    }

    public static String detectContentType(MultipartFile file) {
        return file.getContentType() != null ? file.getContentType() : MediaType.APPLICATION_OCTET_STREAM_VALUE;
    }
}

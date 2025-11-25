package com.fyn_monolithic.service.storage;

import com.fyn_monolithic.model.storage.MediaType;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.GetObjectArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MinioService {

    private final MinioClient minioClient;

    @Value("${minio.bucket-name}")
    private String bucket;

    public String upload(MultipartFile file) {
        try {
            String objectKey = UUID.randomUUID() + "-" + file.getOriginalFilename();
            String contentType = determineContentType(file.getContentType(), file.getOriginalFilename());
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectKey)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(contentType)
                    .build());
            return objectKey;
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to upload file", ex);
        }
    }

    public String upload(byte[] data, String objectName) {
        try {
            String objectKey = objectName != null ? objectName : UUID.randomUUID().toString();
            String contentType = determineContentType(null, objectName);
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectKey)
                    .stream(new ByteArrayInputStream(data), data.length, -1)
                    .contentType(contentType)
                    .build());
            return objectKey;
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to upload file", ex);
        }
    }

    public byte[] download(String objectKey) {
        try (var stream = minioClient.getObject(GetObjectArgs.builder()
                .bucket(bucket)
                .object(objectKey)
                .build())) {
            return stream.readAllBytes();
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to download file", ex);
        }
    }

    public String getPresignedUrl(String objectKey) {
        try {
            return minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .bucket(bucket)
                    .method(Method.GET)
                    .object(objectKey)
                    .build());
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to create pre-signed URL", ex);
        }
    }

    public MediaType detectMediaType(MultipartFile file) {
        String contentType = determineContentType(file.getContentType(), file.getOriginalFilename());
        if (contentType == null) {
            return MediaType.FILE;
        }
        if (contentType.startsWith("image/")) {
            return MediaType.IMAGE;
        }
        if (contentType.startsWith("video/")) {
            return MediaType.VIDEO;
        }
        if (contentType.startsWith("audio/")) {
            return MediaType.AUDIO;
        }
        return MediaType.FILE;
    }

    /**
     * Xác định Content-Type từ contentType hoặc từ filename extension
     * Nếu contentType là null hoặc application/octet-stream, sẽ detect từ extension
     */
    private String determineContentType(String contentType, String filename) {
        // Nếu contentType hợp lệ và không phải application/octet-stream, sử dụng nó
        if (contentType != null && !contentType.equals("application/octet-stream")) {
            return contentType;
        }
        
        // Nếu không có filename, trả về application/octet-stream
        if (filename == null || filename.isEmpty()) {
            return "application/octet-stream";
        }
        
        // Detect từ extension
        String lowerFilename = filename.toLowerCase(Locale.ROOT);
        int lastDot = lowerFilename.lastIndexOf('.');
        if (lastDot == -1 || lastDot == lowerFilename.length() - 1) {
            return "application/octet-stream";
        }
        
        String extension = lowerFilename.substring(lastDot + 1);
        
        // Images
        switch (extension) {
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "png":
                return "image/png";
            case "gif":
                return "image/gif";
            case "webp":
                return "image/webp";
            case "bmp":
                return "image/bmp";
            case "svg":
                return "image/svg+xml";
            case "ico":
                return "image/x-icon";
            // Videos
            case "mp4":
                return "video/mp4";
            case "mov":
                return "video/quicktime";
            case "avi":
                return "video/x-msvideo";
            case "mkv":
                return "video/x-matroska";
            case "webm":
                return "video/webm";
            case "flv":
                return "video/x-flv";
            // Audio
            case "mp3":
                return "audio/mpeg";
            case "wav":
                return "audio/wav";
            case "ogg":
                return "audio/ogg";
            case "m4a":
                return "audio/mp4";
            // Documents
            case "pdf":
                return "application/pdf";
            case "doc":
                return "application/msword";
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "xls":
                return "application/vnd.ms-excel";
            case "xlsx":
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            default:
                return "application/octet-stream";
        }
    }
}

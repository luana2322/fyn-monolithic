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
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectKey)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build());
            return objectKey;
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to upload file", ex);
        }
    }

    public String upload(byte[] data, String objectName) {
        try {
            String objectKey = objectName != null ? objectName : UUID.randomUUID().toString();
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectKey)
                    .stream(new ByteArrayInputStream(data), data.length, -1)
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
        String contentType = file.getContentType();
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
}

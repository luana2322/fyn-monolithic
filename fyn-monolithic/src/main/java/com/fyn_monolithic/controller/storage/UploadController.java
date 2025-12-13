package com.fyn_monolithic.controller.storage;

import com.fyn_monolithic.service.storage.MinioService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class UploadController {

    private final MinioService minioService;

    /**
     * Upload file to MinIO
     */
    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", required = false) String folder) {

        try {
            // Upload to MinIO
            String objectKey = minioService.upload(file);

            // Get presigned URL and replace internal Docker hostname with localhost
            String presignedUrl = minioService.getPresignedUrl(objectKey);
            System.out.println("DEBUG - Original presigned URL: " + presignedUrl);
            String fileUrl = presignedUrl.replace("fyn-minio:9000", "localhost:9000");
            System.out.println("DEBUG - Final file URL: " + fileUrl);

            Map<String, Object> response = new HashMap<>();
            response.put("url", fileUrl);
            response.put("objectKey", objectKey);
            response.put("fileName", file.getOriginalFilename());
            response.put("size", file.getSize());
            response.put("contentType", file.getContentType());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Upload failed: " + e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}

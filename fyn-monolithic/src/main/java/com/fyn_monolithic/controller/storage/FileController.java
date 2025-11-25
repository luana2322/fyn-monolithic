package com.fyn_monolithic.controller.storage;

import com.fyn_monolithic.service.storage.MinioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final MinioService minioService;

    @GetMapping("/{objectKey:.+}")
    public ResponseEntity<byte[]> getFile(@PathVariable String objectKey) {
        try {
            // Decode URL-encoded objectKey
            String decodedKey = java.net.URLDecoder.decode(objectKey, java.nio.charset.StandardCharsets.UTF_8);
            byte[] fileData = minioService.download(decodedKey);
            
            // Determine content type from object key
            String contentType = determineContentType(objectKey);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType(contentType));
            headers.setContentLength(fileData.length);
            headers.setCacheControl("public, max-age=31536000"); // Cache for 1 year
            
            return new ResponseEntity<>(fileData, headers, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    private String determineContentType(String objectKey) {
        String lowerKey = objectKey.toLowerCase();
        if (lowerKey.endsWith(".jpg") || lowerKey.endsWith(".jpeg")) {
            return "image/jpeg";
        } else if (lowerKey.endsWith(".png")) {
            return "image/png";
        } else if (lowerKey.endsWith(".gif")) {
            return "image/gif";
        } else if (lowerKey.endsWith(".webp")) {
            return "image/webp";
        } else if (lowerKey.endsWith(".mp4")) {
            return "video/mp4";
        } else if (lowerKey.endsWith(".pdf")) {
            return "application/pdf";
        }
        return "application/octet-stream";
    }
}

